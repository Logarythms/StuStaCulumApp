//
//  NewsView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

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
                dataManager.updateNews()
                viewModel.updateUpcomingPerformances()
            }
            .listStyle(.plain)
            .navigationTitle("News")
        }
        .onAppear {
            viewModel.updateUpcomingPerformances()
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
