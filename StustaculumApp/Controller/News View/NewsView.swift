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
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    if let logo = dataManager.logo {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
                        Divider()
                    }
                    if !viewModel.upcomingPerformances.isEmpty {
                        Text("Kommende Veranstaltungen")
                            .font(.title2)
                    }
                    ForEach(viewModel.upcomingPerformances) { performance in
                        UpcomingPerformanceView(performance: performance)
                    }
                    Divider()
                    ForEach(dataManager.news) { newsEntry in
                        NewsEntryView(newsEntry: newsEntry)
                        Divider()
                    }
                    
                    Spacer()
                }

            }
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
