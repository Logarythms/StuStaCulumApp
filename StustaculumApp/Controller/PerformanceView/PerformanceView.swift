//
//  PerformanceView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 31.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct PerformanceView: View {
    
    let performance: Performance
    let dataManager = DataManager.shared
    
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
                
                Text(html: performance.description ?? "", size: 15)
                    .padding()
                    .font(.body)
                    .navigationTitle(performance.artist ?? "Veranstaltung")
            }
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
