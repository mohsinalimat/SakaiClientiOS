//
//  HomeController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 4/23/18.

import Foundation
import UIKit
import ReusableSource

/// The controller for the root ViewController of the 'Home' tab and the
/// initial screen for the app.
class HomeController: UITableViewController {

    private lazy var siteTableManager = SiteTableManager(tableView: tableView)

    private var launchedInBackground = false

    var loginService: LoginService?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Classes"
        navigationController?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        // Ensure the rest of the app is locked until the source of truth
        // is loaded
        disableTabs()
        siteTableManager.selectedAt.delegate(to: self) { (self, indexPath) -> Void in
            guard let site = self.siteTableManager.item(at: indexPath) else {
                return
            }
            let classController = ClassController(pages: site.pages)
            self.navigationController?.pushViewController(classController, animated: true)
        }
        siteTableManager.delegate = self

        configureNavigationItem()
        navigationItem.rightBarButtonItem?.isEnabled = false

        // The HomeController must be loaded before any other screens
        // because the SiteTableManager defines the source of truth for
        // the app. So when a reload request is initiated, it will actually
        // trigger 'reloadHome', and the HomeController will in turn trigger
        // the default 'reload' for all other controllers
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: ReloadActions.reload.rawValue),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadData),
            name: Notification.Name(rawValue: ReloadActions.reloadHome.rawValue),
            object: nil
        )

        if UIApplication.shared.applicationState == .background {
            // Do not try and load the screen while in the background. Wait
            // until the view appears so that a software network interrupt
            // is less likely
            launchedInBackground = true
            return
        }

        authenticateAndLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if launchedInBackground {
            authenticateAndLoad()
            launchedInBackground = false
        }
    }

    private func authenticateAndLoad() {
        guard let loginService = loginService else {
            return
        }
        if loginService.loadCookiesFromUserDefaults() {
            let callback = addLoadingIndicator()
            loginService.validateLoggedInStatus(
                onSuccess: { [weak self] in
                    callback()
                    self?.loadData()
                }, onFailure: { [weak self] err in
                    callback()
                    self?.performLoginFlow()
                }
            )
            return
        }

        performLoginFlow()
    }

    private func performLoginFlow() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard
            let navController = storyboard
                .instantiateViewController(withIdentifier: "loginNavigation")
                as? UINavigationController
            else {
                return
        }
        guard
            let loginController = navController.viewControllers.first as? LoginController
            else {
            return
        }
        loginController.onLogin = { [weak self] in
            self?.loadData()
            self?.tabBarController?.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.tabBarController?.present(navController, animated: true, completion: nil)
        }
    }
    
    private func disableTabs() {
        let items = tabBarController?.tabBar.items
        if let arr = items {
            for index in 1..<arr.count {
                arr[index].isEnabled = false
            }
        }
    }
    
    private func enableTabs() {
        let items = tabBarController?.tabBar.items
        if let arr = items {
            for index in 1..<arr.count {
                arr[index].isEnabled = true
            }
        }
    }
}

//MARK: LoadableController Extension

extension HomeController: LoadableController {
    @objc func loadData() {
        siteTableManager.loadDataSourceWithoutCache()
    }
}

//MARK: NetworkSourceDelegate Extension

extension HomeController: NetworkSourceDelegate {
    func networkSourceWillBeginLoadingData<Source>(_ networkSource: Source)
        -> (() -> Void)?
        where Source : NetworkSource {
            // Since every time the HomeController is loaded, the source of
            // truth is set, the rest of the app needs to be locked while
            // data is refreshed and the current source of truth needs to
            // be flushed
            disableTabs()
            SakaiService.shared.reset()
            return addLoadingIndicator()
    }

    func networkSourceSuccessfullyLoadedData<Source>
        (_ networkSource: Source?) where Source : NetworkSource {
        // If the reload was successful, the source of truth was updated,
        // so all other screens in the app should be refreshed to present
        // the newest data
        enableTabs()
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: ReloadActions.reload.rawValue), object: nil)
    }
}

// MARK: UINavigationControllerDelegate Extension

extension HomeController: UINavigationControllerDelegate {
    func navigationController (_ navigationController: UINavigationController,
                               animationControllerFor operation: UINavigationControllerOperation,
                               from fromVC: UIViewController,
                               to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {

            if fromVC is SiteAssignmentController && operation == .push {
                return ExpandPresentAnimationController(resizingDuration: 0.5)
            } else if toVC is SiteAssignmentController && operation == .pop {
                return CollapseDismissAnimationController(resizingDuration: 0.5)
            } else {
                return nil
            }
    }
}
