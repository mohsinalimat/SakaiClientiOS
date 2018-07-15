//
//  AssignmentTableSource.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 7/14/18.
//

import ReusableSource

class AssignmentTableSource: HideableTableSource<AssignmentTableDataProvider, AssignmentTableCell>, NetworkSource {
    
    typealias Fetcher = AssignmentDataFetcher
    
    var fetcher: AssignmentDataFetcher
    var controller: AssignmentController?
    
    required init(provider: AssignmentTableDataProvider, tableView: UITableView) {
        fetcher = AssignmentDataFetcher()
        super.init(provider: provider, tableView: tableView)
    }
    
    convenience init(tableView: UITableView) {
        self.init(provider: AssignmentTableDataProvider(), tableView: tableView)
    }
    
    override func configureBehavior(for cell: AssignmentTableCell, at indexPath: IndexPath) {
        cell.dataSourceDelegate.controller = controller
    }
}
