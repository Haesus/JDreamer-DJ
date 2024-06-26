//
//  JournalListViewModel.swift
//  DJ(DailyJournal)
//
//  Created by 김수영 on 6/6/24.
//

import Foundation
import Combine
import UIKit

class JournalListViewModel: ObservableObject {
    @Published var journals: [Journal] = []
    @Published var summary = ""
    @Published var albumImageViewModel = AlbumImageViewModel()
    @Published var todoListViewModel = TemplateViewModel<TodoTemplateModel>()
    @Published var dailyLogViewModel = TemplateViewModel<DailyTemplateModel>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchJournals() {
        JournalService.shared.fetchJournals()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { documents in
                self.journals = documents
                if !documents.isEmpty {
                    print(documents[0])
                } else {
                    print("journals 없음.")
                }
            }.store(in: &cancellables)
    }
    
    func fetchSummary(_ id: Int) {
        JournalService.shared.fetchSummary(id)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { summary in
                if !summary.summaries.isEmpty {
                    self.summary = summary.summaries[0].summary
                } else {
                    self.summary = "아직 요약이 완성되지 않았어요."
                }
            }.store(in: &cancellables)
    }
    
    func updateJournal(_ journal: UpdatedJournal) {
        JournalService.shared.updateJournal(journal)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Journal 업데이트 성공")
                case .failure(let error):
                    print("Journal 업데이트 실패\(error.localizedDescription)")
                }
            } receiveValue: { updatedJournal in
                if let index = self.journals.firstIndex(where: { $0.id == updatedJournal.id }) {
                    self.journals[index] = updatedJournal
                }
                print(updatedJournal)
            }.store(in: &cancellables)
    }
}
