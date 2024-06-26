//
//  DetailView.swift
//  DJ(DailyJournal)
//
//  Created by 한유진 on 6/7/24.
//

import SwiftUI

struct JournalDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var journalListViewModel: JournalListViewModel
    @State private var isEditing = false
    @State private var editedContent: String
    @State private var isPickerPresented = false
    @State private var selectedImages: [UIImage?]
    @State var photoIndex: Int = 0
    @State var isPhotoChanged = false
    @StateObject var updateJournalViewModel = UpdateJournalViewModel()
    
    let journal: Journal
    let photoCount: Int
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    // TODO: - 고려할 수 있는 사항: init() 과 .onAppear life cycle 에 맞춰서
    init(journal: Journal) {
        self.journal = journal
        self.photoCount = journal.journalImages?.count ?? 0
        _selectedImages = State(initialValue: Array(repeating: nil, count: self.photoCount))
        _editedContent = State(initialValue: journal.journalText)
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(alignment: .leading) {
                HStack {
                    Text(journal.journalTitle)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.top, 10)
                
                ScrollView {
                    HStack {
                        if let hostKey = Bundle.main.hostKey,
                           let journalImages = journal.journalImages {
                            ForEach(0..<photoCount) { index in
                                if let seletedImage = selectedImages[index] {
                                    Image(uiImage: seletedImage)
                                        .resizable()
                                        .aspectRatio(1.0, contentMode: .fit)
                                        .frame(width: screenWidth * 0.9 / CGFloat(photoCount))
                                        .clipped()
                                        .onTapGesture {
                                            if isEditing {
                                                isPickerPresented = true
                                                isPhotoChanged = true
                                                photoIndex = index
                                            }
                                        }
                                } else {
                                    AsyncImage(url: URL(string: "https://\(hostKey)/images/\(journalImages[index].journalImageString)")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: screenWidth * 0.9 / CGFloat(photoCount))
                                            .clipped()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .onTapGesture {
                                        if isEditing {
                                            isPickerPresented = true
                                            isPhotoChanged = true
                                            photoIndex = index
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Image(systemName: "lightbulb.max.fill")
                            .padding(.vertical, 5)
                        Text(journalListViewModel.summary)
                            .onAppear {
                                journalListViewModel.fetchSummary(journal.id)
                            }
                    }
                    
                    VStack(alignment: .leading) {
                        Image(systemName: "note.text")
                            .padding(.top, 5)
                        if isEditing {
                            TextEditor(text: $updateJournalViewModel.journalText)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .lineSpacing(0)
                                .scrollContentBackground(.hidden)
                            
                        } else {
                            Text(editedContent)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 5)
                                .lineSpacing(0)
                        }
                    }
                }
                .refreshable {
                    journalListViewModel.fetchJournals()
                    journalListViewModel.fetchSummary(journal.id)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("저장") {
                            saveChanges()
                        }
                    } else {
                        Button("수정") {
                            isEditing.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("뒤로가기")
                        }
                    }
                }
            }
            .frame(width: screenWidth * 0.9)
            .foregroundStyle(Color.ivory)
            .navigationTitle("내 일기")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .onAppear {
                self.updateJournalViewModel.id = journal.id
                self.updateJournalViewModel.journalText = journal.journalText
                self.updateJournalViewModel.journalImages = Array(repeating: nil, count: photoCount)
                journalListViewModel.fetchSummary(journal.id)
            }
            .sheet(isPresented: $isPickerPresented, content: {
                ImagePicker(image: $selectedImages[photoIndex])
            })
        }
    }
    
    private func saveChanges() {
        if isPhotoChanged {
            let dispatchGroup = DispatchGroup()
            for index in 0..<photoCount {
                dispatchGroup.enter()
                if let selectedImage = selectedImages[index] {
                    updateJournalViewModel.journalImages?[index] = selectedImage
                    dispatchGroup.leave()
                } else if let hostKey = Bundle.main.hostKey,
                          let journalImages = journal.journalImages {
                    let imageURLString = "https://\(hostKey)/images/\(journalImages[index].journalImageString)"
                    if let imageURL = URL(string: imageURLString) {
                        fetchImage(from: imageURL) { image in
                            DispatchQueue.main.async {
                                if let image = image {
                                    updateJournalViewModel.journalImages?[index] = image
                                } else {
                                    print("Failed to load image from URL: \(imageURLString)")
                                }
                                dispatchGroup.leave()
                            }
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                updateJournalViewModel.updateJournal()
            }
        } else {
            updateJournalViewModel.updateJournal()
        }
        
        editedContent = updateJournalViewModel.journalText
        isEditing = false
    }
    
    
    private func cancelEditing() {
        editedContent = journal.journalText
        isEditing = false
        isPhotoChanged = false
        selectedImages = Array(repeating: nil, count: 4)
    }
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                let image = UIImage(data: data)
                completion(image)
            } else {
                print("Error fetching image: \(String(describing: error))")
                completion(nil)
            }
        }.resume()
    }
    
    
    
}

#Preview {
    NavigationView {
        JournalDetailView(journal: journal)
            .environmentObject(JournalViewModel())
            .environmentObject(JournalListViewModel())
    }
}
