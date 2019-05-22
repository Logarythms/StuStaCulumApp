//
//  ViewController.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import UIKit
import SpreadsheetView
import XLPagerTabStrip
import SVProgressHUD

class ScheduleDayViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate, IndicatorInfoProvider {
    
    let dataManager = DataManager.shared
    let notificationCenter = NotificationCenter.default
    
    var performances = [Performance]()
    var favouritePerformances = [Performance]()
    var isFavouritesController = false
    
    var timeslotsDada = [Timeslot]()
    var timeslotsAtrium = [Timeslot]()
    var timeslotsHalle = [Timeslot]()
    var timeslotsZelt = [Timeslot]()
    var timeslotsGelände = [Timeslot]()
    
    var slotInfo = [IndexPath: Performance]()
    
    var selectedPerformance: Performance?

    var day: SSCDay!
    
    var pvc: ButtonBarPagerTabStripViewController?
        
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(loadPerformances), name: Notification.Name("fetchComplete"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(loadPerformances), name: Notification.Name("performancesUpdated"), object: nil)
        
        setupScheduleView()
        loadFavourites()
        
        if self.isFavouritesController {
            reloadFavouriteView()
        } else {
            let performances = dataManager.getPerformancesFor(day)
            splitPerformances(performances: performances)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadFavourites()
        if self.isFavouritesController {
            reloadFavouriteView()
        }
    }
    
    @objc
    func loadPerformances() {
        let performances = dataManager.getPerformancesFor(day)
        splitPerformances(performances: performances)
    }
    
    func reloadFavouriteView() {
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFavorites))
        if  let vc = navigationController?.viewControllers[safe: 0] as? FavouritesMasterViewController {
            vc.navigationItem.rightBarButtonItem = dismissButton
        }
        
        let filteredPerformances = Util.filterPerformancesBy(self.day, performances: self.favouritePerformances)
        self.splitPerformances(performances: filteredPerformances)
    }
    
    @objc
    func dismissFavorites() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadFavourites() {
        guard let path = Util.getFavouritesPath() else { return }
        guard let favouritesData = try? Data(contentsOf: path) else { return }
        guard let favourites = try? JSONDecoder().decode([Performance].self, from: favouritesData) else { return }
        self.favouritePerformances = favourites
    }
    
    func saveFavourites() {
        guard let encodedData = try? JSONEncoder().encode(self.favouritePerformances) else { return }
        guard let favouritesPath = Util.getFavouritesPath() else { return }
        
        do {
            try encodedData.write(to: favouritesPath)
        } catch let error {
            print(error)
        }
        
        if isFavouritesController {
            let filteredPerformances = Util.filterPerformancesBy(self.day, performances: self.favouritePerformances)
            self.splitPerformances(performances: filteredPerformances)
        }
        
    }
    
    func setupScheduleView() {
        spreadsheetView.register(UINib(nibName: String(describing: DadaCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: DadaCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: AtriumCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AtriumCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: HalleCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: HalleCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: ZeltCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ZeltCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: TimeCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: TimeCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: StageCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: StageCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: GeländeCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: GeländeCell.self))
        spreadsheetView.register(EmptyCell.self, forCellWithReuseIdentifier: String(describing: EmptyCell.self))
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.isDirectionalLockEnabled = true
        spreadsheetView.bounces = false
        spreadsheetView.scrollView.isScrollEnabled = false
        spreadsheetView.gridStyle = .solid(width: 1, color: Util.backgroundColor)
        
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
        if indexPath.column == 0 && indexPath.row == 0 {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: StageCell.self), for: indexPath) as? StageCell {
                cell.title.text = ""
                cell.borders.right = .none
                return cell
            }
        }
        
        if indexPath.column == 0 && indexPath.row > 0 {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as? TimeCell {
                let timeStrings = Util.getLabelTextFor(day.minHour + indexPath.row / 60)
                cell.startTimeLabel.text = timeStrings.0
                cell.midTimeLabel.text = timeStrings.1
                
                cell.borders.bottom = .solid(width: 1, color: .darkGray)
                cell.borders.right = .solid(width: 1, color: .darkGray)
                
                return cell
            }
        }
        
        if indexPath.column > 0 && indexPath.row == 0 {
            if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: StageCell.self), for: indexPath) as? StageCell {
                cell.title.text = stageFor(indexPath.column)
                return cell
            }
        }
        
        if let performance = slotInfo[indexPath] {
            switch performance.location {
            case 1:
                if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DadaCell.self), for: indexPath) as? DadaCell {
                    cell.title.text = performance.artist!
                    
                    cell.borders.right = .solid(width: 1, color: .darkGray)
                    cell.borders.bottom = .solid(width: 1, color: .darkGray)
                    
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCellAt))
                    cell.addGestureRecognizer(gestureRecognizer)
                    
                    return cell
                }
            case 2:
                if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: AtriumCell.self), for: indexPath) as? AtriumCell {
                    cell.title.text = performance.artist!
                    
                    cell.borders.right = .solid(width: 1, color: .darkGray)
                    cell.borders.bottom = .solid(width: 1, color: .darkGray)
                    
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCellAt))
                    cell.addGestureRecognizer(gestureRecognizer)
                    
                    return cell
                }
            case 3:
                if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HalleCell.self), for: indexPath) as? HalleCell {
                    cell.title.text = performance.artist!
                    
                    cell.borders.right = .solid(width: 1, color: .darkGray)
                    cell.borders.bottom = .solid(width: 1, color: .darkGray)
                    
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCellAt(sender:)))
                    cell.addGestureRecognizer(gestureRecognizer)
                    
                    return cell
                }
            case 4:
                if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ZeltCell.self), for: indexPath) as? ZeltCell {
                    cell.title.text = performance.artist!
                    
                    cell.borders.right = .solid(width: 1, color: .darkGray)
                    cell.borders.bottom = .solid(width: 1, color: .darkGray)
                    
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCellAt))
                    cell.addGestureRecognizer(gestureRecognizer)
                    
                    return cell
                }
            case 5:
                if let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: GeländeCell.self), for: indexPath) as? GeländeCell {
                    cell.title.text = performance.artist
                    
                    cell.borders.right = .solid(width: 1, color: .darkGray)
                    cell.borders.bottom = .solid(width: 1, color: .darkGray)
                    
                    let gestureRecogizer = UITapGestureRecognizer(target: self, action: #selector(didTapCellAt))
                    cell.addGestureRecognizer(gestureRecogizer)
                    
                    return cell
                }
            default:
                print("lol")
            }
        }
        
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: EmptyCell.self), for: indexPath)
        cell.borders.right = .solid(width: 1, color: .darkGray)
        cell.borders.bottom = .solid(width: 1, color: .darkGray)
        
        return cell
    }
    
    @objc
    func didTapCellAt(sender: UITapGestureRecognizer) {
        let artistTitle: String
        
        if let title = (sender.view as? AtriumCell)?.title.text {
            artistTitle = title
        } else if let title = (sender.view as? DadaCell)?.title.text {
            artistTitle = title
        } else if let title = (sender.view as? HalleCell)?.title.text {
            artistTitle = title
        } else if let title = (sender.view as? ZeltCell)?.title.text {
            artistTitle = title
        } else if let title = (sender.view as? GeländeCell)?.title.text {
            artistTitle = title
        } else {
            return
        }
        
        guard let performance = self.performances.first(where: {
            $0.artist == artistTitle
        }) else {
            return
        }
        self.selectedPerformance = performance
        self.performSegue(withIdentifier: "performanceDetailSegue", sender: self)
    }
    
//    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
//        print("check")
//        if let performance = slotInfo[indexPath] {
//            self.selectedPerformance = performance
//            self.performSegue(withIdentifier: "performanceDetailSegue", sender: self)
//        }
//    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var mergedCells = [CellRange]()
        let hours = day.maxHour - day.minHour
        
        guard !self.performances.isEmpty || isFavouritesController else {
            return mergedCells
        }
        
        for row in 0..<hours {
            mergedCells.append(CellRange(from: (60 * row + 1, 0), to: (60 * (row + 1), 0)))
        }

        var minutes = 0

        for timeslot in timeslotsDada {
            let cellRange = CellRange(from: (minutes + 1, 1), to: (minutes + timeslot.duration, 1))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }

        minutes = 0

        for timeslot in timeslotsAtrium {
            let cellRange = CellRange(from: (minutes + 1, 2), to: (minutes + timeslot.duration, 2))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }

        minutes = 0

        for timeslot in timeslotsHalle {
            let cellRange = CellRange(from: (minutes + 1, 3), to: (minutes + timeslot.duration, 3))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }

        minutes = 0

        for timeslot in timeslotsZelt {
            let cellRange = CellRange(from: (minutes + 1, 4), to: (minutes + timeslot.duration, 4))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }
        
        minutes = 0
        
        for timeslot in timeslotsGelände {
            let cellRange = CellRange(from: (minutes + 1, 5), to: (minutes + timeslot.duration, 5))
            if cellRange.to.row <= spreadsheetView.numberOfRows {
                mergedCells.append(cellRange)
                slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = timeslot.performance
                minutes += timeslot.duration
            }
        }
        
        return mergedCells
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 6
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        guard let currentDay = day else { return 0 }
        if isFavouritesController {
            return (currentDay.duration) * 60 + 1
        } else if performances.isEmpty {
            return 0
        } else {
            return (currentDay.duration) * 60 + 1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 37
        }
        let scheduleWidth = UIScreen.main.bounds.width - 40
        return scheduleWidth / 5
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if row == 0 {
            return 40
        } else {
            return 1
        }
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 5
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        guard !self.performances.isEmpty else {
            return 0
        }
        
        return 1
    }
    
    func stageFor(_ id: Int) -> String {
        switch id {
        case 1:
            return "Café Dada"
        case 2:
            return "Atrium"
        case 3:
            return "Halle"
        case 4:
            return "Zelt"
        case 5:
            return "Gelände"
        default:
            return ""
        }
    }
    
    func splitPerformances(performances: [Performance]) {
        
        self.performances = performances
        
        let timeslots: ([Timeslot], [Timeslot], [Timeslot], [Timeslot], [Timeslot])
        if isFavouritesController {
            timeslots = dataManager.getTimeslotsFor(self.day, favoritePerformances: performances)
        } else {
            timeslots = dataManager.getTimeslotsFor(self.day)
        }
        
        self.timeslotsDada = timeslots.0
        self.timeslotsAtrium = timeslots.1
        self.timeslotsHalle = timeslots.2
        self.timeslotsZelt = timeslots.3
        self.timeslotsGelände = timeslots.4
        
        if UIDevice.current.systemVersion.contains("10") {
            pvc?.moveToViewController(at: 1)
        }
        
        spreadsheetView.reloadData()
        spreadsheetView.reloadData()
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "performanceDetailSegue" {
            guard let performanceVC = segue.destination as? PerformanceDetailViewController else { return }
            guard let performance = self.selectedPerformance else {
                return
            }
            
            performanceVC.performance = performance
            performanceVC.scheduleDayViewController = self
            performanceVC.favourites = self.favouritePerformances
        } else if segue.identifier == "favorite" {
            guard   let navVC = segue.destination as? UINavigationController,
                    let favoritesVC = navVC.viewControllers.first as? ScheduleDayViewController else {
                    
                    return
            }
            favoritesVC.isFavouritesController = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        switch day.day {
        case .day1:
            return "MI."
        case .day2:
            return "DO."
        case .day3:
            return "FR."
        case .day4:
            return "SA."
        }
    }

}

