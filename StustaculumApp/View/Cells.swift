//
//  PerformanceCell.swift
//  StustaculumApp
//
//  Created by Camille Mainz on 21.05.18.
//  Copyright © 2018 stustaculum. All rights reserved.
//

import Foundation
import SpreadsheetView

class PerformanceCell: Cell {
    
    @IBOutlet weak var title: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var color: UIColor = .clear {
        didSet {
            backgroundColor = color
        }
    }
    
}

class TimeCell: Cell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var color: UIColor = .clear {
        didSet {
            backgroundColor = color
        }
    }
    
}

class StageCell: Cell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var color: UIColor = .clear {
        didSet {
            backgroundColor = color
        }
    }
    
}

class EmptyCell: Cell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.7, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
