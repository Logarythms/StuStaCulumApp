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
    
    internal var shadowLayer: CAShapeLayer!
    internal var cornerRadius: CGFloat = 10.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Util.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = Util.backgroundColor
    }
}

class DadaCell: PerformanceCell {
    private let fillColor = Util.dadaColor
    @IBOutlet weak var title: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}

class AtriumCell: PerformanceCell {
    private let fillColor = Util.atriumColor
    @IBOutlet weak var title: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}

class HalleCell: PerformanceCell {
    private let fillColor = Util.halleColor
    @IBOutlet weak var title: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}

class ZeltCell: PerformanceCell {
    private let fillColor = Util.zeltColor
    @IBOutlet weak var title: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}

class TimeCell: Cell {
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var midTimeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Util.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = Util.backgroundColor
    }
    
}

class StageCell: Cell {
    
    @IBOutlet weak var title: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Util.stageCellBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = Util.stageCellBackgroundColor
    }
    
}

class EmptyCell: Cell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Util.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = Util.backgroundColor
    }
}
