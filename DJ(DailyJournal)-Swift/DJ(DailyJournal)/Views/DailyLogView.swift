//
//  DailyLogView.swift
//  DJ(DailyJournal)
//
//  Created by 김수영 on 6/4/24.
//

import SwiftUI
import UIKit



struct DailyLogView: View {
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
      }
    @State private var logItems: [LogItem] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                List {
                    ForEach($logItems) { $logItem in
                        DailyLogRowView(logItem: $logItem)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: removeRows)
                }
                .background(Color.backgroundColor)
                .scrollContentBackground(.hidden)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            addLogItem()
                        }, label: {
                            ZStack {
                                Circle()
                                    .foregroundColor(.lightYellow)
                                    .frame(width: 70, height: 70)
                                Image(systemName: "plus")
                                    .foregroundColor(.ivory)
                                    .font(.system(size: 35, weight: .bold))
                            }
                        })
                        .padding(.bottom, 23)
                        .padding(.trailing, 23)
                    }
                }
            }
            .navigationBarTitle("Daily Log", displayMode: .large)
            
            
        }
    }
    
    private func addLogItem() {
        logItems.append(LogItem())
    }
    
    private func removeRows(at offsets: IndexSet) {
        logItems.remove(atOffsets: offsets)
    }
}


#Preview {
    DailyLogView()
}
