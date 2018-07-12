//
//  HomeController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 4/23/18.

import Foundation
import UIKit
import ReusableSource

class HomeController: UITableViewController {
    
    var siteTableSource: SiteTableSource!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.title = "Classes"
        super.tableView.register(SiteCell.self, forCellReuseIdentifier: SiteCell.reuseIdentifier)
        super.tableView.register(TermHeader.self, forHeaderFooterViewReuseIdentifier: TermHeader.reuseIdentifier)
        siteTableSource = SiteTableSource(tableView: tableView)
        siteTableSource.controller = self
        loadData()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadData))
        //self.setupSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func loadData() {
        disableTabs()
        loadSource() {
            self.enableTabs()
        }
    }
    
    func disableTabs() {
        let items = self.tabBarController?.tabBar.items
        
        if let arr = items {
            for i in 1..<5 {
                arr[i].isEnabled = false
            }
        }
    }
    
    func enableTabs() {
        let items = self.tabBarController?.tabBar.items
        
        if let arr = items {
            for i in 1..<5 {
                arr[i].isEnabled = true
            }
        }
    }
}

extension HomeController: NetworkController {
    var networkSource: SiteTableSource {
        return siteTableSource
    }
}
