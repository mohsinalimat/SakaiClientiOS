//
//  HomeController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 4/23/18.

import Foundation
import UIKit

class HomeController: CollapsibleSectionController {
    
    let TABLE_CELL_HEIGHT:CGFloat = 40.0
    
    var siteDataSource: SiteDataSource = SiteDataSource()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, dataSource: siteDataSource)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classes"
        self.tableView.register(SiteTableViewCell.self, forCellReuseIdentifier: SiteTableViewCell.reuseIdentifier)
        self.tableView.register(TableHeaderView.self, forHeaderFooterViewReuseIdentifier: TableHeaderView.reuseIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.TABLE_CELL_HEIGHT
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.transitionToClass(indexPath: indexPath)
    }
    
    func transitionToClass(indexPath: IndexPath) {
        let storyboard:UIStoryboard = self.storyboard!
        let classController:ClassController = storyboard.instantiateViewController(withIdentifier: "classController") as! ClassController
        let site:Site = self.siteDataSource.sites[indexPath.section][indexPath.row]
        classController.title = site.getTitle()
        classController.setPages(pages: site.getPages())
        self.navigationController?.pushViewController(classController, animated: true)
    }
}
