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
            style:.plain,
            target:self,
            action:#selector(ViewController.collapseSubrows))
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents[section].count
    }
    
    func tableView(_ tableView: UITableView, numberOfSubRowsAt indexPath: IndexPath) -> Int {
        return contents[indexPath.section][indexPath.row].count - 1;
    }
    
    func tableView(_ tableView: UITableView, shouldExpandSubRowsOfCellAtIndexPath indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1 && indexPath.row == 0){
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = FlexibleTableViewCell(style:.default, reuseIdentifier:"cell")
        
        cell.textLabel!.text = contents[indexPath.section][indexPath.row][0]
        
        if ((indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 0)) || (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 2))) {
            cell.expandable = true
        } else {
            cell.expandable = false
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        
        print("didSelectRowAtIndexPath", cell.textLabel?.text ?? "")
    }
    
    func tableView(_ tableView: FlexibleTableView, didSelectSubRowAtIndexPath indexPath: FlexibleIndexPath) {
        let cell = self.tableView(tableView, cellForSubRowAt: indexPath)
        print("didSelectSubRowAtIndexPath", cell.textLabel?.text ?? "")
    }
    
    func tableView(_ tableView: UITableView, cellForSubRowAt indexPath: FlexibleIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.default, reuseIdentifier:"cell")
        cell.backgroundColor=UIColor.groupTableViewBackground
        cell.textLabel!.text = contents[indexPath.section][indexPath.row][indexPath.subRow]
        return cell;
    }
    
    
    @objc func collapseSubrows() {
        tableView.collapseCurrentlyExpandedIndexPaths()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
}
