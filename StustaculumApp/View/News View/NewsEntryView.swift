//
//  NewsEntryView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import SwiftUI

struct NewsEntryView: View {
    
    private let dataDetector: NSDataDetector = {
        let types: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        return try! .init(types: types.rawValue)
    }()
    
    let newsEntry: NewsEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(newsEntry.title)
                .font(.title3)
                .fontWeight(.heavy)
            if let attributedString = attributedString(from: newsEntry.description) {
                Text(attributedString)
                    .font(.subheadline)
                    .fontWeight(.medium)
            } else {
                Text(newsEntry.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
    
    private func attributedString(from text: String) -> AttributedString? {
            var attributed = AttributedString(text)
            let fullRange = NSMakeRange(0, text.count)
            let matches = dataDetector.matches(in: text, options: [], range: fullRange)
            guard !matches.isEmpty else { return nil }
            
            for result in matches {
                guard let range = Range<AttributedString.Index>(result.range, in: attributed) else {
                    continue
                }
                
                switch result.resultType {
                case .phoneNumber:
                    guard
                        let phoneNumber = result.phoneNumber,
                        let url = URL(string: "sms://\(phoneNumber)")
                    else {
                        break
                    }
                    attributed[range].link = url
                    
                case .link:
                    guard let url = result.url else {
                        break
                    }
                    attributed[range].link = url

                default:
                    break
                }
            }
            
            return attributed
        }
}

//struct NewsEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsEntryView()
//    }
//}
