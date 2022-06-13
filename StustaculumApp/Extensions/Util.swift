//
//  Util.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 24.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class Util {
    
    static let dadaColor = UIColor(red:0.35, green:0.57, blue:0.27, alpha:1.0)
    static let atriumColor = UIColor(red:0.56, green:0.26, blue:0.58, alpha:1.0)
    static let halleColor = UIColor(red:0.90, green:0.00, blue:0.33, alpha:1.0)
    static let zeltColor = UIColor(red:0.00, green:0.45, blue:0.64, alpha:1.0)
    static let geländeColor = UIColor(red:0.38, green:0.38, blue:0.38, alpha:1.0)
    
    static let ssc2022Color = UIColor(red: 0.92, green: 0.15, blue: 0.76, alpha: 1.00)
    
    static let backgroundColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.0)
//    static let backgroundColor = UIColor(named: "Background")!
    static let stageCellBackgroundColor = UIColor(red:0.26, green:0.26, blue:0.26, alpha:1.0)
    
    class func getLastUpdatedFor(_ performances: [Performance]?) -> Date {
        if let date = performances?.sorted(by: { $0.lastUpdate >= $1.lastUpdate }).first?.lastUpdate {
            return date
        } else {
            return Date()
        }
    }
    
    class func colorForStage(_ id: Int) -> UIColor {
        switch id {
        case 1:
            return dadaColor
        case 2:
            return atriumColor
        case 3:
            return halleColor
        case 4:
            return zeltColor
        default:
            return dadaColor
        }
    }
    
    class func nameForLocation(_ id: Int) -> String {
        switch id {
        case 1:
            return "Café Dada"
        case 2:
            return "Atrium"
        case 3:
            return "Hans-Scholl-Halle"
        case 4:
            return "Festzelt"
        case 5:
            return "Gelände"
        default:
            return ""
        }
    }
    
    class func httpsURLfor(_ url: URL) -> URL? {
        let urlString = url.relativeString
        let httpsURLString = urlString.replacingOccurrences(of: "http", with: "https")
        return URL(string: httpsURLString)
    }
    
    class func getNotificationTriggers() -> [UNCalendarNotificationTrigger] {
        var triggers = [UNCalendarNotificationTrigger]()
        
        for id in 0...3 {
            var dateComponents = DateComponents()
            dateComponents.timeZone = TimeZone(abbreviation: "CEST")
            dateComponents.year = 2019
            dateComponents.hour = 2
            dateComponents.minute = 0
            
            if (0...2).contains(id) {
                dateComponents.month = 5
            } else {
                dateComponents.month = 6
            }
            
            switch id {
            case 0:
                dateComponents.day = 30
            case 1:
                dateComponents.day = 31
            case 2:
                dateComponents.day = 1
            case 3:
                dateComponents.day = 2
            default:
                break
            }
            
            triggers.append(UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false))
        }
        
        return triggers
    }
    
    static let agbString = "<h1>Allgemeine Nutzungsbedingungen für die Verwendung der App</h1> Anbieter der App ist der Kulturleben in der Studentenstadt e.V. (im Folgenden „Verein Kulturleben“).<br/> <br/> Die Nutzung der App setzt voraus, dass Sie den nachfolgenden Nutzungsbedingungen zustimmen.<br/> <br/> Bitte lesen Sie sich diese deshalb sorgfältig durch. <h2>1. Allgemeines zur Nutzung</h2> In der App stehen Ihnen Informationen zum StuStaCulum, wie das Programm und die Musik der auftretenden Künstler zur Verfügung. Die in der App enthaltenen Inhalte sind auf den persönlichen Gebrauch beschränkt, soweit nicht gesetzliche Ausnahmeregelungen bestehen.<br/> <br/> Mit dem Download der App erwerben Sie keinerlei Urheber- oder gewerbliche Schutzrechte, es sei denn, diese wurden Ihnen explizit eingeräumt.<br/> <br/> Die App und deren Funktionen dürfen nicht in missbräuchlicher Art und Weise verwendet werden. Bei Verstoß gegen geltendes deutsches Recht oder unsere Nutzungsbedingungen behält sich der Verein Kulturleben das Recht vor, Sie von der Nutzung der App auszuschließen. <h2>2. Push-Benachrichtigung</h2> Die App erzeugt standardmäßig Push-Benachrichtigungen, um den Nutzer über verschiedene Dinge zu informieren. Diese Funktion kann nicht deaktiviert werden. <h2>3. Social-Media-Dienste</h2> Die App enthält Verknüpfungen zu Social-Media-Diensten (Facebook, Twitter) und die Möglichkeit zum Versenden von E-Mail-Empfehlungen. <br/> <br/> Diese Funktionalität ist standardmäßig aktiviert und kann nicht deaktiviert werden. <h2>4. Sonstiges</h2> Der Verein Kulturleben arbeitet stetig daran, die App zu optimieren.<br/> Deswegen behält sich der Verein Kulturleben das Recht vor, Funktionen und Features hinzuzufügen oder zu entfernen und eventuell neue Beschränkungen der Dienste einzuführen.<br/> <br/> Sie können jederzeit die Nutzung der App beenden. Der Verein Kulturleben übernimmt keine Garantien hinsichtlich Verfügbarkeit, Zuverlässigkeit, Funktionalität oder Eignung der App für Ihre Zwecke. Eine Haftung für Vorsatz und grobe Fahrlässigkeit richtet sich allein nach den gesetzlichen Vorschriften.<br/> <br/> Eine Haftung für Fahrlässigkeit wird nur übernommen, wenn der VereinKulturleben Kardinalspflichten verletzt hat. Der Verein Kulturleben behält sich das Recht vor, die Nutzungsbedingungen zu ändern und anzupassen.<br/> Hierüber werden Sie in geeigneter Weise informiert."
    
}
