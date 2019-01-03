//
//  TabController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 12/31/18.
//

import UIKit
import LNPopupController

class TabController: UITabBarController, UITabBarControllerDelegate {

    weak var popupController: UIViewController?
    var shouldOpenPopup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        tabBar.tintColor = Palette.main.tabBarTintColor
        tabBar.isTranslucent = true
        tabBar.barStyle = Palette.main.barStyle
        tabBar.unselectedItemTintColor = Palette.main.tabBarUnselectedTintColor
        tabBar.backgroundColor = Palette.main.tabBarBackgroundColor
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if popupController != nil && (viewControllerToPresent is UIDocumentPickerViewController ||
            viewControllerToPresent is UIImagePickerController) {
            shouldOpenPopup = true
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let navController = selectedViewController as? UINavigationController
        let index = selectedIndex
        let itemIndex = tabBar.items?.index(of: item)
        if index == itemIndex && navController?.viewControllers.first is HomeController {
            dismissPopupBar(animated: true, completion: nil)
            navController?.popToRootViewController(animated: true)
            navController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}
