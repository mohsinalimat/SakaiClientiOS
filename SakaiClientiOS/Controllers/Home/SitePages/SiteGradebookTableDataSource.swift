//
//  SiteGradebookTableDataSource.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 7/18/18.
//

import ReusableSource

class SiteGradebookTableDataSource: ReusableTableDataSource<SingleSectionDataProvider<GradeItem>, GradebookCell>, NetworkSource {
    typealias Fetcher = SiteGradebookDataFetcher
    
    let fetcher: SiteGradebookDataFetcher
    weak var delegate: NetworkSourceDelegate?
    
    convenience init(tableView: UITableView, siteId: String) {
        let fetcher = SiteGradebookDataFetcher(siteId: siteId)
        self.init(provider: SingleSectionDataProvider<GradeItem>(), fetcher: fetcher, tableView: tableView)
    }

    init(provider: Provider, fetcher: Fetcher, tableView: UITableView) {
        self.fetcher = fetcher
        super.init(provider: provider, tableView: tableView)
    }
    
    override func setup() {
        super.setup()
        tableView.allowsSelection = false
    }
}
