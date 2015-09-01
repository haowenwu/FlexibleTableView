//
//  FlexibleTableViewCell.swift
//  FlexibleTableView
//
//  Created by 吴浩文 on 15/7/29.
//  Copyright (c) 2015年 吴浩文. All rights reserved.
//

import UIKit

public class FlexibleTableViewCell: UITableViewCell {
    public var expanded = false
    public var expandable = true {
        didSet{
            if (expandable) {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 8))
                let layer = CAShapeLayer()
                let path = UIBezierPath()
                path.moveToPoint(CGPointMake(0, 0))
                path.addLineToPoint(CGPointMake(8, 8))
                path.addLineToPoint(CGPointMake(16, 0))
                layer.path = path.CGPath;
                layer.strokeColor = UIColor.darkGrayColor().CGColor
                layer.fillColor = UIColor.clearColor().CGColor
                view.layer.addSublayer(layer)
                self.accessoryView = view
            }
        }
    }
    
    let kIndicatorViewTag = -1
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {super.init(style: style, reuseIdentifier: reuseIdentifier)}
    required public init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    
    public func accessoryViewAnimation() {
        UIView.animateWithDuration(0.2){
            if (self.expanded) {
                self.accessoryView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
            } else {
                self.accessoryView!.transform = CGAffineTransformMakeRotation(0);
            }
        }
    }
}

public class FlexibleTableViewCellIndicator: UIView {
    public var indicatorColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clearColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        CGContextClosePath(context);
        
        CGContextSetFillColorWithColor(context, indicatorColor!.CGColor);
        CGContextFillPath(context);
    }
}