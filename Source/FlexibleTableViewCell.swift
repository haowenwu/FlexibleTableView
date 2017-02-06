//
//  FlexibleTableViewCell.swift
//  FlexibleTableView
//
//  Created by 吴浩文 on 15/7/29.
//  Copyright (c) 2015年 吴浩文. All rights reserved.
//

import UIKit

open class FlexibleTableViewCell: UITableViewCell {
    open var expanded = false
    open var expandable = true {
        didSet{
            if (expandable) {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 8))
                let layer = CAShapeLayer()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 8, y: 8))
                path.addLine(to: CGPoint(x: 16, y: 0))
                layer.path = path.cgPath;
                layer.strokeColor = UIColor.darkGray.cgColor
                layer.fillColor = UIColor.clear.cgColor
                view.layer.addSublayer(layer)
                self.accessoryView = view
            }
        }
    }
    
    let kIndicatorViewTag = -1
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {super.init(style: style, reuseIdentifier: reuseIdentifier)}
    required public init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    
    open func accessoryViewAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            if (self.expanded) {
                self.accessoryView?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            } else {
                self.accessoryView?.transform = CGAffineTransform(rotationAngle: 0);
            }
        })
    }
}

open class FlexibleTableViewCellIndicator: UIView {
    open var indicatorColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext();
        
        context!.beginPath();
        context!.move   (to: CGPoint(x: rect.minX, y: rect.maxY));
        context!.addLine(to: CGPoint(x: rect.midX, y: rect.minY));
        context!.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY));
        context!.closePath();
        
        context!.setFillColor(indicatorColor!.cgColor);
        context!.fillPath();
    }
}
