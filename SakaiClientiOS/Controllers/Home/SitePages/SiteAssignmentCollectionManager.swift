//
//  SiteAssignmentCollectionManager.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 7/24/18.
//

import ReusableSource

class SiteAssignmentCollectionManager: AssignmentCollectionManager, NetworkSource {
    typealias Fetcher = SiteAssignmentDataFetcher
    
    let fetcher: SiteAssignmentDataFetcher
    weak var delegate: NetworkSourceDelegate?

    override var scrollPosition: UICollectionViewScrollPosition {
        return .centeredVertically
    }
    
    convenience init(collectionView: UICollectionView, siteId: String) {
        let provider = SingleSectionDataProvider<Assignment>()
        let fetcher = SiteAssignmentDataFetcher(siteId: siteId, networkService: RequestManager.shared)
        self.init(provider: provider, fetcher: fetcher, collectionView: collectionView)
    }

    init(provider: Provider, fetcher: Fetcher, collectionView: UICollectionView) {
        self.fetcher = fetcher
        super.init(provider: provider, collectionView: collectionView)
    }
    
    override func setup() {
        super.setup()
        collectionView.backgroundColor = Palette.main.primaryBackgroundColor
        collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        collectionView.indicatorStyle = Palette.main.scrollViewIndicatorStyle
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 280 * 0.7
        let size: CGSize = CGSize(width: collectionView.bounds.width / 2.25, height: height)
        return size
    }
}
