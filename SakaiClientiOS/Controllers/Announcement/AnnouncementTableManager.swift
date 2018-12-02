//
//  AnnouncementTableManager.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 7/15/18.
//

import ReusableSource

class AnnouncementTableManager: ReusableTableManager<AnnouncementDataProvider, AnnouncementCell>, NetworkSource {

    typealias Fetcher = AnnouncementDataFetcher

    var isLoading = false
    weak var delegate: NetworkSourceDelegate?

    var fetcher: AnnouncementDataFetcher
    
    convenience init(tableView: UITableView) {
        self.init(fetcher: AnnouncementDataFetcher(), provider: AnnouncementDataProvider(), tableView: tableView)
    }

    init(fetcher: Fetcher, provider: Provider, tableView: UITableView) {
        self.fetcher = fetcher
        super.init(provider: provider, tableView: tableView)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = super.tableView(tableView, cellForRowAt: indexPath) as? AnnouncementCell else {
            return UITableViewCell()
        }
        
        if indexPath.row >= provider.lastIndex() - 10 && fetcher.moreLoads && !isLoading {
            isLoading = true
            loadMoreData()
        }
        
        return cell
    }
    
    override func resetValues() {
        fetcher.resetOffset()
        provider.resetValues()
    }

    func loadMoreData() {
        let frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(70))
        let spinner = LoadingIndicator(frame: frame)
        spinner.activityIndicatorViewStyle = .gray
        spinner.startAnimating()
        spinner.hidesWhenStopped = true

        tableView.tableFooterView = spinner
        tableView.tableFooterView?.isHidden = false
        fetcher.loadData(completion: { [weak self] announcements, err in
            DispatchQueue.main.async {
                guard err == nil else {
                    self?.delegate?.networkSourceFailedToLoadData(self, withError: err!)
                    self?.isLoading = false
                    return
                }
                spinner.stopAnimating()
                guard let items = announcements else {
                    self?.isLoading = false
                    return
                }
                self?.loadItems(payload: items)
                self?.reloadData()
                self?.isLoading = false
            }
        })
    }
}

extension AnnouncementTableManager {
    var siteId: String? {
        get {
            return fetcher.siteId
        } set {
            fetcher.siteId = newValue
        }
    }
}
