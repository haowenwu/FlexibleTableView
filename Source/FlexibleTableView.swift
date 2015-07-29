//
//  FlexibleTableView.swift
//  FlexibleTableView
//
//  Created by 吴浩文 on 15/7/29.
//
//

import UIKit

@objc public protocol FlexibleTableViewDelegate: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: FlexibleTableView, numberOfSubRowsAtIndexPath indexPath: NSIndexPath) -> Int
    func tableView(tableView: FlexibleTableView, cellForSubRowAtIndexPath indexPath: FlexibleIndexPath) -> UITableViewCell
    optional func tableView(tableView: FlexibleTableView, heightForSubRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    optional func tableView(tableView: FlexibleTableView, didSelectSubRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: FlexibleTableView, shouldExpandSubRowsOfCellAtIndexPath indexPath: NSIndexPath) -> Bool
}

public class FlexibleIndexPath: NSObject{
    public var subRow: Int, row: Int, section: Int
    init(forSubRow subrow:Int,inRow row:Int,inSection section:Int){
        self.subRow = subrow
        self.row=row
        self.section=section
    }
    
    required public init(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
}

public class FlexibleTableView : UITableView, UITableViewDelegate, UITableViewDataSource {
    public var flexibleTableViewDelegate: FlexibleTableViewDelegate
    public var shouldExpandOnlyOneCell = false
    
    let kIsExpandedKey = "isExpanded"
    let kSubrowsKey = "subrowsCount"
    let kDefaultCellHeight = 44.0
    
    public let expandableCells = NSMutableDictionary()
    
    init(frame: CGRect,delegate: FlexibleTableViewDelegate) {
        flexibleTableViewDelegate = delegate
        super.init(frame: frame, style: .Plain)
        self.delegate=self
        self.dataSource=self
        refreshData()
    }
    required public init(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return flexibleTableViewDelegate.tableView(tableView, numberOfRowsInSection:section) + numberOfExpandedSubrowsInSection(section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
        let nsIndexPath = NSIndexPath(forRow: correspondingIndexPath.row, inSection: correspondingIndexPath.section)
        if correspondingIndexPath.subRow == 0 {
            let expandableCell = flexibleTableViewDelegate.tableView(tableView, cellForRowAtIndexPath:nsIndexPath) as! FlexibleTableViewCell
            
            let isExpanded = (expandableCells[correspondingIndexPath.section] as! NSMutableArray)[correspondingIndexPath.row][kIsExpandedKey] as! Bool
            
            if (expandableCell.expandable) {
                expandableCell.expanded = isExpanded;
                
                //let expandableButton = expandableCell.accessoryView
                //expandableButton?.addGestureRecognizer(<#gestureRecognizer: UIGestureRecognizer#>)
                
                if (isExpanded){
                    //expandableCell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
                } else if (expandableCell.containsIndicatorView()) {
                    expandableCell.removeIndicatorView()
                }
            } else {
                expandableCell.expanded = false
                expandableCell.accessoryView = nil;
                expandableCell.removeIndicatorView()
            }
            
            return expandableCell;
        }
        else{
            let cell = flexibleTableViewDelegate.tableView(tableView as! FlexibleTableView, cellForSubRowAtIndexPath:correspondingIndexPath)
            cell.backgroundColor = separatorColor
            cell.backgroundView = nil;
            cell.indentationLevel = 2;
            
            return cell;
        }
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if flexibleTableViewDelegate.respondsToSelector("numberOfSectionsInTableView:") {
            return flexibleTableViewDelegate.numberOfSectionsInTableView!(tableView)
        }
        return 1;
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FlexibleTableViewCell
        
        if cell.respondsToSelector("isExpandable") {
            if cell.expandable {
                cell.expanded = false
                
                var _indexPath = indexPath
                let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(_indexPath)
                let nsIndexPath = NSIndexPath(forRow: correspondingIndexPath.row, inSection: correspondingIndexPath.section)
                if (cell.expanded && shouldExpandOnlyOneCell) {
                    _indexPath = nsIndexPath;
                    collapseCurrentlyExpandedIndexPaths()
                }
                
                let numberOfSubRows = numberOfSubRowsAtIndexPath(nsIndexPath)
                
                let expandedIndexPaths = NSMutableArray()
                let row = _indexPath.row;
                let section = _indexPath.section;
                
                for var index = 1; index <= numberOfSubRows; index++ {
                    let expIndexPath = NSIndexPath(forRow:row+index, inSection:section)
                    expandedIndexPaths.addObject(expIndexPath)
                }
                
                if (cell.expanded)
                {
                    setExpanded(true, forCellAtIndexPath:nsIndexPath)
                    insertRowsAtIndexPaths(expandedIndexPaths as [AnyObject], withRowAnimation:UITableViewRowAnimation.Top)
                }
                else
                {
                    setExpanded(false, forCellAtIndexPath:nsIndexPath)
                    deleteRowsAtIndexPaths(expandedIndexPaths as [AnyObject], withRowAnimation:UITableViewRowAnimation.Top)
                }
                
                cell.accessoryViewAnimation()
            }
            
            if flexibleTableViewDelegate.respondsToSelector("tableView:didSelectRowAtIndexPath:") {
                let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
                let nsIndexPath = NSIndexPath(forRow: correspondingIndexPath.row, inSection: correspondingIndexPath.section)
                
                if (correspondingIndexPath.subRow == 0) {
                    flexibleTableViewDelegate.tableView!(tableView, didSelectRowAtIndexPath:nsIndexPath)
                } else {
                    flexibleTableViewDelegate.tableView!(self, didSelectSubRowAtIndexPath:nsIndexPath)
                }
            }
        } else {
            let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
            flexibleTableViewDelegate.tableView?(self, didSelectSubRowAtIndexPath:NSIndexPath(forRow: correspondingIndexPath.row, inSection: correspondingIndexPath.section))
        }
    }
    
    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        flexibleTableViewDelegate.tableView?(tableView, accessoryButtonTappedForRowWithIndexPath:indexPath)
        delegate!.tableView?(tableView, didSelectRowAtIndexPath:indexPath)
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
        let nsIndexPath = NSIndexPath(forRow: correspondingIndexPath.row, inSection: correspondingIndexPath.section)
        if correspondingIndexPath.subRow == 0 {
            if flexibleTableViewDelegate.respondsToSelector("tableView:heightForRowAtIndexPath:") {
                return flexibleTableViewDelegate.tableView!(tableView, heightForRowAtIndexPath:nsIndexPath)
            }
            return 44.0;
        } else {
            if flexibleTableViewDelegate.respondsToSelector("tableView:heightForSubRowAtIndexPath:") {
                return flexibleTableViewDelegate.tableView!(self, heightForSubRowAtIndexPath:nsIndexPath)
            }
            return 44.0;
        }
    }
    
    public func numberOfExpandedSubrowsInSection(section: Int) -> Int {
        var totalExpandedSubrows = 0;
        
        let rows = expandableCells[section] as! [NSDictionary]
        for row in rows {
            if row[kIsExpandedKey] as! Bool {
                totalExpandedSubrows += row[kSubrowsKey] as! Int
            }
        }
        return totalExpandedSubrows;
    }
    
    @IBAction func expandableButtonTouched(sender: AnyObject, event:AnyObject) {
        let touches = event.allTouches()
        if let firstTouch = touches!.first as? UITouch{
            let currentTouchPosition = firstTouch.locationInView(self)
            
            let indexPath = indexPathForRowAtPoint(currentTouchPosition)
            
            if indexPath != nil {
                tableView(self, accessoryButtonTappedForRowWithIndexPath:indexPath!)
            }
        }
    }
    
    public func numberOfSubRowsAtIndexPath(indexPath: NSIndexPath) -> Int {
        return flexibleTableViewDelegate.tableView(self, numberOfSubRowsAtIndexPath:indexPath)
    }
    
    func correspondingIndexPathForRowAtIndexPath(indexPath: NSIndexPath) -> FlexibleIndexPath {
        var correspondingIndexPath: FlexibleIndexPath
        var expandedSubrows = 0;
        
        let rows = self.expandableCells[indexPath.section] as! NSArray
        for (index, value) in enumerate(rows) {
            let isExpanded = value[self.kIsExpandedKey] as! Bool
            var numberOfSubrows = 0;
            if (isExpanded){
                numberOfSubrows = value[self.kSubrowsKey] as! Int
            }
            
            var subrow = indexPath.row - expandedSubrows - index;
            if (subrow > numberOfSubrows){
                expandedSubrows += numberOfSubrows;
            }
            else{
                return FlexibleIndexPath(forSubRow: subrow, inRow: index, inSection: indexPath.section)
            }
        }
        return FlexibleIndexPath(forSubRow: 0, inRow: 0, inSection: 0)
    }
    
    public func setExpanded(isExpanded: Bool, forCellAtIndexPath indexPath: NSIndexPath) {
        let cellInfo = (expandableCells[indexPath.section] as! NSMutableArray)[indexPath.row] as! NSMutableDictionary
        cellInfo.setObject(isExpanded, forKey:kIsExpandedKey)
    }
    
    public func collapseCurrentlyExpandedIndexPaths() {
        let totalExpandedIndexPaths = NSMutableArray()
        let totalExpandableIndexPaths = NSMutableArray()
        
        for x in expandableCells {
            var totalExpandedSubrows = 0;
            
            for (index, value) in enumerate(x.value as! NSArray) {
                
                let currentRow = index + totalExpandedSubrows;
                
                if (value[kIsExpandedKey] as! Bool)
                {
                    let expandedSubrows = value[kSubrowsKey] as! Int
                    for (var index = 1; index <= expandedSubrows; index++)
                    {
                        let expandedIndexPath = NSIndexPath(forRow:currentRow + index, inSection:x.key as! Int)
                        totalExpandedIndexPaths.addObject(expandedIndexPath)
                    }
                    
                    value.setObject(false, forKey:kIsExpandedKey)
                    totalExpandedSubrows += expandedSubrows;
                    
                    totalExpandableIndexPaths.addObject(NSIndexPath(forRow:currentRow, inSection:x.key as! Int))
                }
            }
        }
    
        
        for indexPath in totalExpandableIndexPaths
        {
            let cell = cellForRowAtIndexPath(indexPath as! NSIndexPath) as! FlexibleTableViewCell
            cell.expanded = false
            cell.accessoryViewAnimation()
        }
        
        deleteRowsAtIndexPaths(totalExpandedIndexPaths as [AnyObject], withRowAnimation:UITableViewRowAnimation.Top)
    }
    
    public func refreshData(){
        expandableCells.removeAllObjects()
        for var section = 0; section < numberOfSections(); section++ {
            let numberOfRowsInSection = flexibleTableViewDelegate.tableView(self, numberOfRowsInSection:section)
            let rows = NSMutableArray()
            for var row = 0; row < numberOfRowsInSection; row++ {
                let rowIndexPath = NSIndexPath(forRow:row, inSection:section)
                let numberOfSubrows = flexibleTableViewDelegate.tableView(self, numberOfSubRowsAtIndexPath:rowIndexPath)
                var isExpandedInitially = false
                if flexibleTableViewDelegate.respondsToSelector("tableView:shouldExpandSubRowsOfCellAtIndexPath:") {
                    isExpandedInitially = flexibleTableViewDelegate.tableView!(self, shouldExpandSubRowsOfCellAtIndexPath:rowIndexPath)
                }
                let rowInfo = NSMutableDictionary(objects:[isExpandedInitially, numberOfSubrows], forKeys:[kIsExpandedKey, kSubrowsKey])
                rows.addObject(rowInfo)
            }
            expandableCells.setObject(rows, forKey:section)
        }
        super.reloadData()
    }
}