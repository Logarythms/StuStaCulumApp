//
//  PerformanceView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI
import HTMLString
import HTML2Markdown

struct PerformanceView: View {
    
    let performance: Performance
    let dataManager = DataManager.shared
    let splitMarkdownStrings: [AttributedString]
    
    init(performance: Performance) {
        self.performance = performance
        
        let dom = try? HTMLParser().parse(html: (performance.description ?? "").removingHTMLEntities())
        let markdownString = dom?.toMarkdown(options: .unorderedListBullets) ?? ""
        
        self.splitMarkdownStrings = markdownString.split(separator: "\n").map {
            if let attributedString = try? AttributedString(markdown: String($0)) {
                return attributedString
            } else {
                return AttributedString()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                VStack(alignment: .leading) {
                    let description = performance.getEventDescription()
                    LocationLabel(locationName: description.locationName, locationColor: description.locationColor)
                    Text(getFormattedDateString())
                        .font(.subheadline)
                        .bold()
                    Text(try! AttributedString(markdown: "**Genre:** \(performance.genre ?? "")"))
                        .font(.subheadline)
                }
                .padding([.leading, .trailing])
                
                if let url = performance.imageURL {
                    AsyncImage(url: Util.httpsURLfor(url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .centered()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(10)
                                .centered()
                        default:
                            EmptyView()
                        }
                    }
                    .centered()
                } else if let logo = dataManager.logo {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .centered()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(splitMarkdownStrings, id: \.self) { string in
                        Text(string)
                            .font(.system(size: 15))
                    }
                }
                .padding([.leading, .trailing])
            }
            .navigationTitle(performance.artist ?? "Veranstaltung")
        }
    }
    
    func getFormattedDateString() -> String {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        weekdayFormatter.locale = Locale.init(identifier: "de_DE")
        
        let dateString = "\(weekdayFormatter.string(from: performance.date)) \(hourFormatter.string(from: performance.date)) - \(hourFormatter.string(from: performance.endDate())) Uhr"
        
        return dateString
    }
}

//struct PerformanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        PerformanceView()
//    }
//}
