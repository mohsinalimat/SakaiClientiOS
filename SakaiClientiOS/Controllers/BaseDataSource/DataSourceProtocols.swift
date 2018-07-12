//
//  DataSourceProtocols.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 6/2/18.
//

import Foundation
import UIKit

protocol BaseTableDataSource : UITableViewDataSource {
    var numRows:[Int] { get set }
    var numSections:Int { get set }
    
    var hasLoaded:Bool { get set }
    var isLoading:Bool { get set }
    
    func loadData(completion: @escaping () -> Void)
    func resetValues()
}

protocol BaseHideableTableDataSource : BaseTableDataSource{
    var isHidden:[Bool] { get set }
    var terms:[Term] { get set }
}

protocol SearchableDataSource {
    
    func searchAndFilter(for text:String)
}
