//
//  PreviewProvider.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 12.06.22.
//  Copyright © 2022 stustaculum. All rights reserved.
//

import Foundation

struct SSCPreviewProvider {
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    static var performanceJSON  =
    """
    {
        "id": 3319,
        "artist": "Torrential Rain",
        "description": "Deutschlands Progressive Metalcore Newcomer TORRENTIAL RAIN holen Dich dort ab, wo die Alltagsspirale nach unten zieht. Liebesspielereien, Trennungsschmerz, tiefste Ängste oder der Blick in die eigene Seele sind nur einige Themen, mit denen die Nürnberger in ihren Songs den Gedanken und Gefühlen freien Lauf lassen und in 85 Ländern weltweit ihren Fans zeigen: Du bist nicht allein!<br /> <br /> Gepaart mit dem Leitsatz “Power meets precision” vereinen sie das Unvereinbare: die brachiale Energie von Bands wie August Burns Red und Polaris mit der progressiv-virtuosen Spielweise á la Periphery. Die Nürnberger erschaffen eine perfekte Symbiose dieser beiden Welten, in der sich Urgewalt und feinfühliger Tiefgang die Waage halten und bringen diese amerikanischen Trends als Novum auf die Bühnen Europas.<br /> <br /> Szenegrößen wie Kvelertak, Equilibrium, Illumenium oder Time, The Valuator haben bereits das beeindruckende musikalische Potenzial von TORRENTIAL RAIN erkannt und sie als Support mit auf die Bühne geholt, wo sie Fans aller möglichen Genre-Lager auf 70 Shows in der aktuellen Besetzung mit sich reißen konnten.<br /> <br /> Mit den vier Singles „HOME ALONE“, „STRUNG OUT“, „DEAF EARS“ und „LEFT OUTSIDE“, aus dem letzten Jahr, spielte sich TORRENTIAL RAIN mit über 370.000 Streams in die Playlisten und Herzen ihrer Fans. Zum krönenden Abschluss des Jahres 2020 wurde die jüngste Veröffentlichung Teil der weltweit bekannten Spotify Editorial Playlists „NEW METAL TRACKS“ und „NEW BLOOD“.",
        "genre": "Metalcore",
        "date": "2022-06-15T20:00:00Z",
        "duration": 45,
        "image_url": "http://app.stustaculum.de/media/images/3319_workaround.jpg",
        "last_update": "2022-05-29T15:49:53Z",
        "show": true,
        "location": 2,
        "stustaculum": 6
    }
    """
    
    static var performance = try! decoder.decode(Performance.self, from: performanceJSON.data(using: .utf8)!)
}
