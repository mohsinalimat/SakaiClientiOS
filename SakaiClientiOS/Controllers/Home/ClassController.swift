//
//  ClassController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 5/11/18.
//

import UIKit

class ClassController: UITableViewController {

    var sitePages:[SitePage] = [SitePage]()
    var numSections = 1
    
    override func loadView() {
        let customTable: UITableView = UITableView(frame: .zero, style: UITableViewStyle.plain)
        customTable.dataSource = self
        customTable.delegate = self
        self.view = customTable
        self.tableView = customTable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(SiteCell.self, forCellReuseIdentifier: SiteCell.reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sitePages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SiteCell.reuseIdentifier, for: indexPath) as? SiteCell else {
            fatalError("Not a Site Table View Cell")
        }
        let page:SitePage = sitePages[indexPath.row]
        cell.titleLabel.text = page.getTitle()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let page:SitePage = self.sitePages[indexPath.row]
        
        var controller:UIViewController
        
        switch(page.getSiteType()) {
        case is GradebookPageController.Type:
            controller = GradebookPageController(siteId: page.getSiteId(), style: UITableViewStyle.plain)
            print("Is Gradebook Controller")
            break
        default:
            controller = DefaultController()
            print("Is Default")
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setPages(pages: [SitePage]) {
        sitePages = pages
    }
}