//
//  NewsView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI
import AlertToast

struct NewsView: View {
    
    @ObservedObject var dataManager = DataManager.shared
    @ObservedObject var viewModel = NewsViewModel()
        
    var body: some View {
        NavigationView {
            List{
                if let logo = dataManager.logo {
                    Section {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .centered()
                    }
                    .listRowSeparator(.hidden)
                }
                
                Section {
                    ForEach(viewModel.upcomingPerformances) { performance in
                        NavigationLink {
                            PerformanceView(performance: performance)
                        } label: {
                            UpcomingPerformanceCell(performance: performance)
                        }

                    }
                } header: {
                    Text("Kommende Veranstaltungen")
                        .font(.title3)
                        .fontWeight(.heavy)
                }

                Section {
                    ForEach(dataManager.news) { newsEntry in
                        NewsEntryView(newsEntry: newsEntry)
                    }
                } header: {
                    if !dataManager.news.isEmpty {
                        Text("Meldungen")
                            .font(.title3)
                            .fontWeight(.heavy)
                    } else {
                        EmptyView()
                    }
                }
            }
            .refreshable {
                viewModel.updateUpcomingPerformances()
                Task(priority: .userInitiated) {
                    try? await dataManager.updatePerformances()
                }
                Task(priority: .userInitiated) {
                    try? await dataManager.updateNews()
                }
                Task(priority: .userInitiated) {
                    try? await dataManager.updateHowTos()
                }
            }
            .listStyle(.plain)
            .navigationTitle("News")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.updateUpcomingPerformances()
        }
        .toast(isPresenting: $dataManager.notificationEnabledToast, duration: 1) {
            AlertToast(displayMode: .hud, type: .systemImage("bell.fill", .red), title: "Benachrichtigung An")
        }
        .toast(isPresenting: $dataManager.notificationDisabledToast, duration: 1) {
            AlertToast(displayMode: .hud, type: .systemImage("bell.slash.fill", .red), title: "Benachrichtigung Aus")
        }
        .toast(isPresenting: $dataManager.notificationErrorToast, duration: 1) {
            AlertToast(displayMode: .hud, type: .error(.red), title: "Fehler")
        }
    }
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
            .previewDisplayName("iPhone 13")
    }
}

class NewsViewHostingController: UIHostingController<NewsView> {

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: NewsView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
