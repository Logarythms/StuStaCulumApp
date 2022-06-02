//
//  FaqDetailView.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 30.05.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation
import SwiftUI
import HTML2Markdown
import HTMLString

struct FaqDetailView: View {
    let howTo: HowTo
    let splitMarkdownStrings: [AttributedString]
    
    init(howTo: HowTo) {
        self.howTo = howTo
        
        let kinderProgrammStrings = ["Auch in diesem Jahr gibt es zu folgenden Zeiten wieder ein abwechslungsreiches Programm für unsere kleinen Gäste am Kinderplatz:", "**Mittwoch, 15.06.22 ab 15 Uhr**", "**Donnerstag, 16.06.22 ab 15 Uhr**", "**Freitag, 17.06.22 ab 15 Uhr**", "**Samstag, 18.06.22 ab 15 Uhr**"]
                
        let dom = try? HTMLParser().parse(html: howTo.description.removingHTMLEntities())
        let markdownString = dom?.toMarkdown(options: .unorderedListBullets) ?? ""
        
        if howTo.title != "Kinderprogramm" {
            self.splitMarkdownStrings = markdownString.split(separator: "\n").map {
                if let attributedString = try? AttributedString(markdown: String($0)) {
                    return attributedString
                } else {
                    return AttributedString()
                }
            }
        } else {
            self.splitMarkdownStrings = kinderProgrammStrings.map {
                if let attributedString = try? AttributedString(markdown: String($0)) {
                    return attributedString
                } else {
                    return AttributedString()
                }
            }
        }
    }

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(splitMarkdownStrings, id: \.self) { string in
                    Text(string)
                }
            }
        }
        .padding()
        .navigationTitle(howTo.title)
    }
}

//struct FaqDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        FaqDetailView()
//    }
//}
