//
//  LoadingIndicator.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 5/12/18.
//

import UIKit

/// A default ActivityIndicator to be used across the app
class LoadingIndicator: UIActivityIndicatorView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.color = UIColor.black
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    
    /// Instantiates an ActivityIndicatorView and then adds it to the center of a superview
    ///
    /// - Parameters:
    ///   - frame: the frame for the Indicator
    ///   - view: The view to which the loading indicator should be added
    convenience init(frame: CGRect, view: UIView) {
        self.init(frame: frame)
        self.center = CGPoint(x: view.center.x, y: view.center.y - 80)
        view.addSubview(self)
    }
    
    convenience init(view: UIView) {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.init(frame: frame, view: view)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
