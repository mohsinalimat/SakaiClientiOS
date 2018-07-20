//
//  WebController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 6/17/18.
//

import UIKit
import WebKit

class WebController: UIViewController {

    var webView: WKWebView!
    var url:URL?
    var shouldLoad: Bool = true
    var needsToolbar: Bool = true
    
    /**
     
     Sets the webview delegates for navigation and UI to the view controller itself,
     allowing the view controller to directly control the webview appearance and requests
     
     */
    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = RequestManager.shared.processPool
        webView = WKWebView(frame: .zero, configuration: configuration)
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if needsToolbar {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pop))
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        if shouldLoad {
            loadURL(urlOpt: url)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadURL(urlOpt:URL?) {
        guard let url = urlOpt else {
            return
        }
        
        webView.load(URLRequest(url: url))
        shouldLoad = false
    }
    
    func setURL(url:URL) {
        self.url = url
    }
    
    @objc func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func canRotate() -> Void {
        
    }
}

class WebViewNavigationController: UINavigationController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        // fix webview input-file dismiss-twice bug
        if let _ = self.presentedViewController {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}

extension UIViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let webController = WebController()
        webController.setURL(url: URL)
        
        self.navigationController?.pushViewController(webController, animated: true)
        
        return false
    }
}