//
//  FlexibleTableView.swift
//  FlexibleTableView
//
//  Created by 吴浩文 on 15/7/29.
//  Copyright (c) 2015年 吴浩文. All rights reserved.
//

import UIKit

@objc public protocol FlexibleTableViewDelegate: NSObjectProtocol {
    func tableView(tableView: FlexibleTableView, numberOfRowsInSection section: Int) -> Int
    func tableView(tableView: FlexibleTableView, numberOfSubRowsAtIndexPath indexPath: NSIndexPath) -> Int
    func tableView(tableView: FlexibleTableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> FlexibleTableViewCell
    func tableView(tableView: FlexibleTableView, cellForSubRowAtIndexPath indexPath: FlexibleIndexPath) -> UITableViewCell
    optional func numberOfSectionsInTableView(tableView: FlexibleTableView) -> Int
    optional func tableView(tableView: FlexibleTableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    optional func tableView(tableView: FlexibleTableView, heightForSubRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    optional func tableView(tableView: FlexibleTableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: FlexibleTableView, didSelectSubRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: FlexibleTableView, heightForHeaderInSection section: Int) -> CGFloat
    optional func tableView(tableView: FlexibleTableView, heightForFooterInSection section: Int) -> CGFloat
    optional func tableView(tableView: FlexibleTableView, titleForHeaderInSection section: Int) -> String?
    optional func tableView(tableView: FlexibleTableView, titleForFooterInSection section: Int) -> String?
    optional func tableView(tableView: FlexibleTableView, viewForHeaderInSection section: Int) -> UIView?
    optional func tableView(tableView: FlexibleTableView, viewForFooterInSection section: Int) -> UIView?
    optional func tableView(tableView: FlexibleTableView, shouldExpandSubRowsOfCellAtIndexPath indexPath: NSIndexPath) -> Bool
}

public class FlexibleIndexPath: NSObject{
    public var subRow: Int, row: Int, section: Int, ns: NSIndexPath
    init(forSubRow subrow:Int,inRow row:Int,inSection section:Int){
        self.subRow = subrow
        self.row=row
        self.section=section
        self.ns=NSIndexPath(forRow: row, inSection: section)
    }
}

public class FlexibleTableView : UITableView, UITableViewDelegate, UITableViewDataSource {
    public var flexibleTableViewDelegate: FlexibleTableViewDelegate
    public var shouldExpandOnlyOneCell = false
    
    let kIsExpandedKey = "isExpanded"
    let kSubrowsKey = "subrowsCount"
    let kDefaultCellHeight = 44.0
    
    public let expandableCells = NSMutableDictionary()
    
    public init(frame: CGRect,delegate: FlexibleTableViewDelegate) {
        flexibleTableViewDelegate = delegate
        super.init(frame: frame, style: .Plain)
        self.delegate=self
        self.dataSource=self
        refreshData()
    }
    required public init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
        if correspondingIndexPath.subRow == 0 {
            let expandableCell = flexibleTableViewDelegate.tableView(self, cellForRowAtIndexPath:correspondingIndexPath.ns)
            
            if (expandableCell.expandable) {
                expandableCell.expanded = (expandableCells[correspondingIndexPath.section] as! NSMutableArray)[correspondingIndexPath.row][kIsExpandedKey] as! Bool
                if (expandableCell.expanded){
                    expandableCell.accessoryView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
                }
            }
            return expandableCell;
        } else {
            let cell = flexibleTableViewDelegate.tableView(self, cellForSubRowAtIndexPath:correspondingIndexPath)
            cell.indentationLevel = 2
            return cell;
        }
    }
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let x = cell as? FlexibleTableViewCell {
            if x.expandable {
                x.expanded = !x.expanded
                
                var _indexPath = indexPath
                let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(_indexPath)
                if (x.expanded && shouldExpandOnlyOneCell) {
                    _indexPath = correspondingIndexPath.ns;
                    collapseCurrentlyExpandedIndexPaths()
                }
                
                let numberOfSubRows = numberOfSubRowsAtIndexPath(correspondingIndexPath.ns)
                
                var expandedIndexPaths = [NSIndexPath]()
                let row = _indexPath.row;
                let section = _indexPath.section;
                
                for var index = 1; index <= numberOfSubRows; index++ {
                    let expIndexPath = NSIndexPath(forRow:row+index, inSection:section)
                    expandedIndexPaths.append(expIndexPath)
                }
                
                if (x.expanded)
                {
                    setExpanded(true, forCellAtIndexPath:correspondingIndexPath)
                    insertRowsAtIndexPaths(expandedIndexPaths, withRowAnimation:UITableViewRowAnimation.Top)
                }
                else
                {
                    setExpanded(false, forCellAtIndexPath:correspondingIndexPath)
                    deleteRowsAtIndexPaths(expandedIndexPaths, withRowAnimation:UITableViewRowAnimation.Top)
                }
                
                x.accessoryViewAnimation()
            }
            
            if flexibleTableViewDelegate.respondsToSelector("tableView:didSelectRowAtIndexPath:") {
                let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
                
                if (correspondingIndexPath.subRow == 0) {
                    flexibleTableViewDelegate.tableView!(self, didSelectRowAtIndexPath:correspondingIndexPath.ns)
                } else {
                    flexibleTableViewDelegate.tableView!(self, didSelectSubRowAtIndexPath:correspondingIndexPath.ns)
                }
            }
            
        }
        else
        {
            if flexibleTableViewDelegate.respondsToSelector("tableView:didSelectSubRowAtIndexPath:"){
                let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
                
                flexibleTableViewDelegate.tableView!(self, didSelectSubRowAtIndexPath:correspondingIndexPath.ns)
            }
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
    
    public func numberOfSubRowsAtIndexPath(indexPath: NSIndexPath) -> Int {
        return flexibleTableViewDelegate.tableView(self, numberOfSubRowsAtIndexPath:indexPath)
    }
    
    func correspondingIndexPathForRowAtIndexPath(indexPath: NSIndexPath) -> FlexibleIndexPath {
        var expandedSubrows = 0;
        
        let rows = self.expandableCells[indexPath.section] as! NSArray
        for (index, value) in rows.enumerate() {
            let isExpanded = value[self.kIsExpandedKey] as! Bool
            var numberOfSubrows = 0;
            if (isExpanded){
                numberOfSubrows = value[self.kSubrowsKey] as! Int
            }
            
            let subrow = indexPath.row - expandedSubrows - index;
            if (subrow > numberOfSubrows){
                expandedSubrows += numberOfSubrows;
            }
            else{
                return FlexibleIndexPath(forSubRow: subrow, inRow: index, inSection: indexPath.section)
            }
        }
        return FlexibleIndexPath(forSubRow: 0, inRow: 0, inSection: 0)
    }
    
    public func setExpanded(isExpanded: Bool, forCellAtIndexPath indexPath: FlexibleIndexPath) {
        let cellInfo = (expandableCells[indexPath.section] as! NSMutableArray)[indexPath.row] as! NSMutableDictionary
        cellInfo.setObject(isExpanded, forKey:kIsExpandedKey)
    }
    
    public func collapseCurrentlyExpandedIndexPaths() {
        var totalExpandedIndexPaths = [NSIndexPath]()
        let totalExpandableIndexPaths = NSMutableArray()
        
        for x in expandableCells {
            var totalExpandedSubrows = 0;
            
            for (index, value) in (x.value as! NSArray).enumerate() {
                
                let currentRow = index + totalExpandedSubrows;
                
                if (value[kIsExpandedKey] as! Bool)
                {
                    let expandedSubrows = value[kSubrowsKey] as! Int
                    for (var index = 1; index <= expandedSubrows; index++)
                    {
                        let expandedIndexPath = NSIndexPath(forRow:currentRow + index, inSection:x.key as! Int)
                        totalExpandedIndexPaths.append(expandedIndexPath)
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
        
        deleteRowsAtIndexPaths(totalExpandedIndexPaths, withRowAnimation:UITableViewRowAnimation.Top)
    }
    
    public func refreshData(){
        expandableCells.removeAllObjects()
        for var section = 0; section < numberOfSections; section++ {
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
    
    
    
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if flexibleTableViewDelegate.respondsToSelector("numberOfSectionsInTableView:") {
            return flexibleTableViewDelegate.numberOfSectionsInTableView!(self)
        }
        return 1;
    }
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return flexibleTableViewDelegate.tableView(self, numberOfRowsInSection:section) + numberOfExpandedSubrowsInSection(section)
    }
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        let correspondingIndexPath = correspondingIndexPathForRowAtIndexPath(indexPath)
        if correspondingIndexPath.subRow == 0 {
            if flexibleTableViewDelegate.respondsToSelector("tableView:heightForRowAtIndexPath:") {
                return flexibleTableViewDelegate.tableView!(self, heightForRowAtIndexPath:correspondingIndexPath.ns)
            }
            return 44.0;
        } else {
            if flexibleTableViewDelegate.respondsToSelector("tableView:heightForSubRowAtIndexPath:") {
                return flexibleTableViewDelegate.tableView!(self, heightForSubRowAtIndexPath:correspondingIndexPath.ns)
            }
            return 44.0;
        }
    }
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if flexibleTableViewDelegate.respondsToSelector("tableView:heightForHeaderInSection:") {
            return flexibleTableViewDelegate.tableView!(self, heightForHeaderInSection: section)
        }
        return 0.0
    }
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if flexibleTableViewDelegate.respondsToSelector("tableView:heightForFooterInSection:") {
            return flexibleTableViewDelegate.tableView!(self, heightForFooterInSection: section)
        }
        return 0.0
    }
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if flexibleTableViewDelegate.respondsToSelector("tableView:titleForHeaderInSection:") {
            return flexibleTableViewDelegate.tableView!(self, titleForHeaderInSection: section)
        }
        return nil
    }
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if flexibleTableViewDelegate.respondsToSelector("tableView:titleForFooterInSection:") {
            return flexibleTableViewDelegate.tableView!(self, titleForFooterInSection: section)
        }
        return nil
    }
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if flexibleTableViewDelegate.respondsToSelector("tableView:viewForHeaderInSection:") {
            return flexibleTableViewDelegate.tableView!(self, viewForHeaderInSection: section)
        }
        return nil
    }
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if flexibleTableViewDelegate.respondsToSelector("tableView:viewForFooterInSection:") {
            return flexibleTableViewDelegate.tableView!(self, viewForFooterInSection: section)
        }
        return nil
    }
}