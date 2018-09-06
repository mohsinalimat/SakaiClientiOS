//
//  AssignmentTableManager.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 7/14/18.
//

import ReusableSource

class AssignmentTableManager: HideableNetworkTableManager<AssignmentTableDataProvider, AssignmentTableCell, AssignmentDataFetcher> {
    
    var lastSelectedIndex: Int?
    
    var textViewDelegate = Delegated<Void, UITextViewDelegate>()
    
    init(tableView: UITableView) {
        super.init(provider: AssignmentTableDataProvider(), fetcher: AssignmentDataFetcher(), tableView: tableView)
    }
    
    override func setup() {
        super.setup()
        tableView.allowsSelection = false
    }
    
    override func configureBehavior(for cell: AssignmentTableCell, at indexPath: IndexPath) {
        if provider.dateSorted {
            cell.titleLabel.text = "All Assignments"
        }
        cell.manager.selectedAt.delegate(to: self) { (self, cellIndexPath) -> Void in
            self.lastSelectedIndex = cellIndexPath.row
            self.selectedAt.call(indexPath)
        }
        cell.manager.textViewDelegate.delegate(to: self) { (self, voidInput) -> UITextViewDelegate? in
            return self.textViewDelegate.call()
        }
    }
    
    func resetSort() {
        provider.dateSorted = false
    }
    
    func switchSort() {
        provider.dateSorted = !provider.dateSorted
        reloadData()
    }
}
