//
//  PagesController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 6/17/18.
//

import UIKit
import LNPopupController
import SafariServices

/// The container view controller allowing pagination between multiple
/// Assignments
class PagesController: UIViewController {

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = Palette.main.highlightColor
        pageControl.pageIndicatorTintColor = Palette.main.pageIndicatorTintColor
        return pageControl
    }()
    private let pageControlView = UIView()
    private let pageController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)

    // Even when the current Assignment changes, the popup controller
    // instance will be the same but the popup URL will change
    private let webController = WebController(allowsOptions: false)
    private lazy var popupController = WebViewNavigationController(rootViewController: webController)
    private let submitPopupBarController = SubmitPopupBarController()

    private var pendingIndex: Int?
    private var pages: [UIViewController?]
    private let assignments: [Assignment]
    private let start: Int

    private var bottomConstraint, topConstraint: NSLayoutConstraint?

    weak var delegate: PagesControllerDelegate?

    init(assignments: [Assignment], start: Int) {
        self.assignments = assignments
        self.start = start
        pages = [UIViewController?](repeating: nil, count: assignments.count)
        super.init(nibName: nil, bundle: nil)
        setPage(assignment: assignments[start], index: start)
    }

    override func loadView() {
        view = UIView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let pageView = pageController.view else {
            return
        }
        view.addSubview(pageView)
        pageView.constrainToEdges(of: view, onSides: [.left, .right])

        let margins = view.layoutMarginsGuide
        // Keep track of bottom and top margins so they can be readjusted,
        // when transitioning away from screen
        topConstraint = pageView.topAnchor.constraint(equalTo: margins.topAnchor)
        bottomConstraint = pageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        topConstraint?.isActive = true; bottomConstraint?.isActive = true

        // Configure the LNPopupController instance
        setPopupURL(viewControllerIndex: start)
        webController.dismissAction = { [weak self] in
            self?.tabBarController?.closePopup(animated: true, completion: nil)
        }

        tabBarController?.popupInteractionStyle = .default
        tabBarController?.popupBar.backgroundStyle = .regular
        tabBarController?.popupBar.customBarViewController = submitPopupBarController

        submitPopupBarController.titleLabel.text = "DRAG TO SUBMIT"

        guard let startPage = pages[start] else {
            return
        }
        pageController.setViewControllers([startPage], direction: .forward, animated: false, completion: nil)
        pageController.dataSource = self
        pageController.delegate = self

        pageControl.numberOfPages = assignments.count
        pageControl.currentPage = start
        pageControlView.addSubview(pageControl)
        navigationItem.titleView = pageControlView
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        guard let tabBarController = tabBarController as? TabController else {
            return
        }
        // If a new tab is selected, the UITabBarController will handle
        // presentation and dismissal of the popup bar
        if tabBarController.isMovingToNewTabFromPages {
            tabBarController.isMovingToNewTabFromPages = false
            return
        }
        tabBarController.dismissPopupBar(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false;

        guard let tabBarController = tabBarController as? TabController else {
            return
        }
        tabBarController.popupController = popupController

        if tabBarController.shouldOpenPopup {
            // If the user is trying to submit, presenting the Document
            // Picker or Image Picker will dismiss the popup due to a
            // WebKit bug. So, the popup should be reopened once the picker
            // has dismissed and should not reload the page to save any
            // potential submission
            webController.setNeedsLoad(to: false)
            tabBarController.presentPopupBar(withContentViewController: popupController,
                                             openPopup: true,
                                             animated: true,
                                             completion: nil)
            tabBarController.shouldOpenPopup = false
        } else {
            tabBarController.presentPopupBar(withContentViewController: popupController,
                                             animated: true,
                                             completion: nil)
        }
        // When popping back to PagesController, LNPopupController
        // encounters a bug where it is entirely removed from the view
        // hierarchy and causes a black space to appear in its place.
        // Adding the views back to the tabBarController manually fixes
        // the bug.
        tabBarController.view.addSubview(tabBarController.popupBar)
        tabBarController.view.addSubview(tabBarController.popupContentView)
    }
}

extension PagesController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
        setPopupURL(viewControllerIndex: viewControllerIndex)

        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }

        if pages[previousIndex] == nil {
            setPage(assignment: assignments[previousIndex], index: previousIndex)
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
                                
        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
        setPopupURL(viewControllerIndex: viewControllerIndex)

        let nextIndex = viewControllerIndex + 1
        let assignmentsCount = assignments.count
        
        guard nextIndex < assignmentsCount else {
            return nil
        }
        if pages[nextIndex] == nil {
            setPage(assignment: assignments[nextIndex], index: nextIndex)
        }
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {

        pendingIndex = pages.index(of: pendingViewControllers.first)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if completed, let index = pendingIndex {
            pageControl.currentPage = index
            delegate?.pageController(self, didMoveToIndex: index)
        }
    }

    private func setPage(assignment: Assignment, index: Int) {
        let page = AssignmentPageController(assignment: assignment)
        page.textViewDelegate = self
        page.scrollViewDelegate = self
        pages[index] = page
    }

    private func setPopupURL(viewControllerIndex: Int) {
        let assignment = assignments[viewControllerIndex]
        guard let url = URL(string: assignment.siteURL) else {
            return
        }
        webController.title = assignment.title
        webController.setURL(url: url)
        webController.setNeedsLoad(to: true)
    }
}

// MARK: Animatable Extension

extension PagesController: Animatable {
    var containerView: UIView? {
        return view
    }

    var childView: UIView? {
        return pageController.view
    }

    func dismissingView(sizeAnimator: UIViewPropertyAnimator, fromFrame: CGRect, toFrame: CGRect) {
        childView?.layer.cornerRadius = AssignmentCell.cornerRadius
        childView?.layer.borderWidth = 0.5
        childView?.layer.borderColor = Palette.main.borderColor.cgColor
        childView?.layoutIfNeeded()

        topConstraint?.isActive = false
        bottomConstraint?.isActive = false
        // If left constrained the margins rather than the views actual
        // edges, the collapsing animation would have compressed the actual
        // view between ugly black margins on the top and bottom of the
        // "card" it is transitioning to
        childView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        childView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension PagesController: NavigationAnimatable {
    func animationControllerForPop(to controller: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if controller is AssignmentController || controller is SiteAssignmentController {
            return CollapseDismissAnimationController(resizingDuration: 0.5)
        }
        return nil
    }

    func animationControllerForPush(to controller: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}