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
    
    var indicator: LoadingIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SiteTableViewCell.self, forCellReuseIdentifier: "siteTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sitePages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "siteTableViewCell", for: indexPath) as? SiteTableViewCell else {
            fatalError("Not a Site Table View Cell")
        }
        let page:SitePage = self.sitePages[indexPath.row]
        cell.titleLabel.text = page.getTitle()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let page:SitePage = self.sitePages[indexPath.row]
        
        //self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setPages(pages: [SitePage]) {
        self.sitePages = pages
    }

}
