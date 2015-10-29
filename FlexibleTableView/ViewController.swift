//
//  ViewController.swift
//  FlexibleTableView
//
//  Created by 吴浩文 on 15/7/27.
//
//

import UIKit

class ViewController: UIViewController, FlexibleTableViewDelegate {
    let contents = [
        [
            ["Section0_Row0", "Row0_Subrow1","Row0_Subrow2"],
            ["Section0_Row1", "Row1_Subrow1", "Row1_Subrow2", "Row1_Subrow3"],
            ["Section0_Row2"]],
        [
            ["Section1_Row0", "Row0_Subrow1", "Row0_Subrow2", "Row0_Subrow3"],
            ["Section1_Row1"]]
    ]
    var tableView: FlexibleTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = FlexibleTableView(frame: view.frame, delegate: self)
        view.addSubview(tableView)
        
        navigationItem.title = "FlexibleTableView";
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Collapse",
            style:.Plain,
            target:self,
            action:"collapseSubrows")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return contents.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return contents[section].count
    }
    
    func tableView(tableView: UITableView, numberOfSubRowsAtIndexPath indexPath: NSIndexPath) -> Int
    {
        return contents[indexPath.section][indexPath.row].count - 1;
    }
    
    func tableView(tableView: UITableView, shouldExpandSubRowsOfCellAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if (indexPath.section == 1 && indexPath.row == 0){
            return true
        }
        
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = FlexibleTableViewCell(style:.Default, reuseIdentifier:"cell")
        
        cell.textLabel!.text = contents[indexPath.section][indexPath.row][0]
        
        if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 0)) || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 2))) {
            cell.expandable = true
        } else {
            cell.expandable = false
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, cellForSubRowAtIndexPath indexPath: FlexibleIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.Default, reuseIdentifier:"cell")
        cell.backgroundColor=UIColor.groupTableViewBackgroundColor()
        cell.textLabel!.text = contents[indexPath.section][indexPath.row][indexPath.subRow]
        return cell;
    }
    
    
    func collapseSubrows() {
        tableView.collapseCurrentlyExpandedIndexPaths()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
}