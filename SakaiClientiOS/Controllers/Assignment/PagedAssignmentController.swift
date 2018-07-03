//
//  PagedAssignmentController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 6/17/18.
//

import UIKit
import LNPopupController

class PagedAssignmentController: UIPageViewController {

    var pages: [UIViewController?] = [UIViewController]()
    var assignments: [Assignment] = [Assignment]()
    var start:Int = 0
    var popupController: WebController = WebController()
    var pageControl:UIPageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        popupController.title = "Drag to Submit"
        
        self.tabBarController?.popupInteractionStyle = .default
        self.tabBarController?.popupBar.backgroundStyle = .dark
        self.tabBarController?.popupBar.barStyle = .compact
        self.tabBarController?.popupBar.barTintColor = AppGlobals.SAKAI_RED
        
        self.setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        self.tabBarController?.presentPopupBar(withContentViewController: popupController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
    }
    
    func setAssignments(assignments: [Assignment], start: Int) {
        self.pages = [UIViewController?](repeating: nil, count: assignments.count)
        self.assignments = assignments
        self.start = start
        setPage(assignment: self.assignments[start], index: start)
        setPopupURL(viewControllerIndex: start)
    }
    
    func setup() {
        guard let startPage = pages[start] else {
            return
        }
        setViewControllers([startPage], direction: .forward, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension PagedAssignmentController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    
    func setPage(assignment:Assignment, index: Int) {
        let page = AssignmentPageController()
        page.assignment = assignment
        pages[index] = page
    }
    
    func setPopupURL(viewControllerIndex:Int) {
        let assignment = assignments[viewControllerIndex]
        guard let url = assignment.getURL() else {
            return
        }
        popupController.setURL(url: URL(string: url)!)
    }
}
