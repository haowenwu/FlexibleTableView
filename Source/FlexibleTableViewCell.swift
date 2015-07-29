//
//  FlexibleTableViewCell.swift
//  FlexibleTableView
//
//  Created by 吴浩文 on 15/7/29.
//
//

import UIKit

public class FlexibleTableViewCell: UITableViewCell {
    public var expanded = false
    public var expandable = true {
        didSet{
            if (expandable) {
                /*
                if (!_image) {
                    _image = [UIImage imageNamed:@"expandableImage.png"];
                }
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                CGRect frame = CGRectMake(0.0, 0.0, _image.size.width, _image.size.height);
                button.frame = frame;
                
                [button setBackgroundImage:_image forState:UIControlStateNormal];
                
                return button;
                
                setAccessoryView(button)*/
            }
        }
    }
    
    let kIndicatorViewTag = -1
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        if (self.expanded) {
            if !containsIndicatorView() {
                addIndicatorView()
            } else {
                removeIndicatorView()
                addIndicatorView()
            }
        }
    }
    
    
    public func addIndicatorView() {/*
        let point = self.accessoryView!.center;
        let bounds = self.accessoryView!.bounds;
        
        let frame = CGRectMake((point.x - CGRectGetWidth(bounds) * 1.5), point.y * 1.4, CGRectGetWidth(bounds) * 3.0, CGRectGetHeight(self.bounds) - point.y * 1.4);
        let indicatorView = FlexibleTableViewCellIndicator(frame:frame)
        indicatorView.tag = kIndicatorViewTag;
        contentView.addSubview(indicatorView)*/
    }
    
    public func removeIndicatorView() {
        contentView.viewWithTag(kIndicatorViewTag)?.removeFromSuperview()
    }
    
    public func containsIndicatorView() -> Bool {
        return (self.contentView.viewWithTag(kIndicatorViewTag) != nil) ? true : false;
    }
    
    public func accessoryViewAnimation() {
        /*
        [UIView animateWithDuration:0.2 animations:^{
        if (self.isExpanded) {
        
        self.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
        
        } else {
        self.accessoryView.transform = CGAffineTransformMakeRotation(0);
        }
        } completion:^(BOOL finished) {
        
        if (!self.isExpanded)
        [self removeIndicatorView];
        
        }];*/
    }
}

public class FlexibleTableViewCellIndicator: UIView {
    public var indicatorColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clearColor()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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