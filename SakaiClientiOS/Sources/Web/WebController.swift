//
//  WebController.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 6/17/18.
//

import UIKit
import WebKit
import SafariServices

/// A WKWebView controller to display and navigate custom Sakai webpages
/// and data.
///
/// Should be used across app to display any web page or content needing
/// Sakai authentication cookies to access URL. Any insecure HTTP URL will
/// be opened in SFSafariViewController instead
class WebController: UIViewController {

    private var webView: WKWebView!
    private var edgeInteractionController: LeftEdgeInteractionController!

    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        progressView.tintColor = Palette.main.highlightColor
        return progressView
    }()

    private let backButton: UIBarButtonItem = {
        let backButtonImage = UIImage(named: "back_button")
        let backButton = UIBarButtonItem(image: backButtonImage,
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        return backButton
    }()

    private let forwardButton: UIBarButtonItem = {
        let forwardButtonImage = UIImage(named: "forward_button")
        let forwardButton = UIBarButtonItem(image: forwardButtonImage,
                                            style: .plain,
                                            target: nil,
                                            action: nil)
        return forwardButton
    }()

    private let interactionButton = UIBarButtonItem(barButtonSystemItem: .action,
                                                    target: nil,
                                                    action: nil)
    private let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                             target: nil,
                                             action: nil)
    private let actionController = UIAlertController(title: nil,
                                                     message: nil,
                                                     preferredStyle: .actionSheet)
    private var interactionController: UIDocumentInteractionController?

    private var url: URL?
    private var didInitialize = false

    var shouldLoad = true

    // Determines wheter action button to download and open in safari should
    // be displayed
    var allowsOptions = true

    /// Manage SFSafariViewController presentation for non-Sakai URL
    lazy var openInSafari: ((URL?) -> Void) = { [weak self] url in
        guard let url = url, url.absoluteString.contains("http") else {
            return
        }
        let safariController = SFSafariViewController.defaultSafariController(url: url)
        self?.shouldLoad = false
        self?.tabBarController?.present(safariController,
                                        animated: true,
                                        completion: nil)
    }

    /// Manage dismissing action for webView
    @objc lazy var dismissWebView: (() -> Void) = { [weak self] in
        self?.navigationController?.popViewController(animated: true)
    }

    private let downloadService: DownloadService
    private let webService: WebService

    init(downloadService: DownloadService, webService: WebService) {
        self.downloadService = downloadService
        self.webService = webService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(:coder) is not supported")
    }

    convenience init() {
        self.init(downloadService: RequestManager.shared,
                  webService: RequestManager.shared)
    }

    deinit {
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            progressView.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        WKWebView.authorizedWebView(webService: webService) { [weak self] webView in
            webView.uiDelegate = self
            webView.navigationDelegate = self
            if let view = self?.view {
                view.addSubview(webView)
                webView.constrainToEdges(of: view)
            }

            if let target = self {
                webView.addObserver(target,
                                    forKeyPath: #keyPath(WKWebView.estimatedProgress),
                                    options: .new,
                                    context: nil)
                target.edgeInteractionController = LeftEdgeInteractionController(view: webView, in: target)
            }

            webView.allowsBackForwardNavigationGestures = false

            self?.webView = webView
            self?.loadURL(urlOpt: self?.url)
            self?.didInitialize = true
        }

        super.viewDidLoad()
        setupProgressBar()
        setupNavBar()
        setupToolbar()
        setupActionSheet()
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldLoad && didInitialize {
            loadURL(urlOpt: url)
        }
        if webView != nil {
            webView.scrollView.isScrollEnabled = true
        }
        navigationController?.navigationBar.tintColor = Palette.main.toolBarColor
        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if webView != nil {
            webView.scrollView.isScrollEnabled = false
        }
        if isMovingFromParentViewController && UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        navigationController?.navigationBar.tintColor = Palette.main.navigationTintColor
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        view.setNeedsLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }

    func loadURL(urlOpt: URL?) {
        guard let url = urlOpt else {
            return
        }
        if !shouldLoad {
            return
        }
        webView.load(URLRequest(url: url))
        shouldLoad = false
    }

    func setURL(url: URL?) {
        self.url = url
    }

    /// Download from URL and present DocumentInteractionController to act
    /// on downloaded file. While file is being downloaded, lock the UI
    /// to prevent leaving the screen until the callback has returned.
    ///
    /// Prevents leaving ViewController until Download has called back -
    /// for success or failure
    /// - Parameter url: the URL to download from
    func downloadAndPresentInteractionController(url: URL?) {
        guard let url = url else {
            return
        }
        interactionButton.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        webView.isHidden = true
        let indicator = LoadingIndicator(view: self.view)
        indicator.startAnimating()

        let didComplete = { [weak self] in
            self?.webView.isHidden = false
            self?.navigationItem.leftBarButtonItem?.isEnabled = true
            self?.interactionButton.isEnabled = true
        }

        downloadService.downloadToDocuments(url: url) { [weak self] fileUrl in
            indicator.stopAnimating()
            indicator.removeFromSuperview()
            guard let fileUrl = fileUrl else {
                didComplete()
                return
            }
            guard let button = self?.interactionButton else {
                didComplete()
                return
            }
            self?.interactionController = UIDocumentInteractionController(url: fileUrl)
            DispatchQueue.main.async {
                self?.interactionController?.presentOpenInMenu(from: button, animated: true)
                didComplete()
            }
        }
    }
}

// MARK: WKUIDelegate and WKNavigationDelegate

extension WebController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if !url.absoluteString.contains("https") {
            decisionHandler(.cancel)
            openInSafari(url)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            [weak self] in
            self?.progressView.isHidden = true
        }
        // Prevent 3D-touch peek and show due to WebKit bug where view
        // controller is dismissed twice
        webView.evaluateJavaScript(
            "document.body.style.webkitTouchCallout='none';"
        )

        // Remove distracting and unintuitive HTML elements from Sakai
        // interface. This includes scrolling navigation bar and other
        // cluttering elements
        webView.evaluateJavaScript("""
            $('.Mrphs-topHeader').remove();
            $('.Mrphs-siteHierarchy').remove();
            $('#toolMenuWrap').remove();
            $('#skipNav').remove();
            var selectedElement = document.querySelector('#content');
            document.body.innerHTML = selectedElement.innerHTML;
        """)
    }

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: View setup and controller configuration

fileprivate extension WebController {
    func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissWebController))
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                            target: self,
                                                            action: #selector(loadWebview))
    }

    /// Attach progress bar to navigation bar frame to track webView loads
    func setupProgressBar() {
        navigationController?.navigationBar.addSubview(progressView)
        guard
            let navigationBarBounds = navigationController?.navigationBar.bounds else {
            return
        }
        progressView.frame = CGRect(x: 0,
                                    y: navigationBarBounds.size.height - 2,
                                    width: navigationBarBounds.size.width,
                                    height: 15)
    }

    /// Configure navigation toolbar with webView action buttons
    func setupToolbar() {
        backButton.target = self;
        backButton.action = #selector(goBack)
        forwardButton.target = self;
        forwardButton.action = #selector(goForward)
        interactionButton.target = self;
        interactionButton.action = #selector(presentDownloadOption)

        var arr: [UIBarButtonItem] = [backButton,
                                      flexButton,
                                      forwardButton,
                                      flexButton,
                                      flexButton,
                                      flexButton]
        if allowsOptions {
            arr.append(interactionButton)
        }
        setToolbarItems(arr, animated: true)
    }

    /// Configure action sheet to present Download and Open in Safari option
    /// for a file/URL
    func setupActionSheet() {
        let downloadAction = UIAlertAction(title: "Download",
                                           style: .default) {
                                            [weak self] (_) in
            self?.downloadAndPresentInteractionController(url: self?.url)
        }
        let safariAction = UIAlertAction(title: "Open in Safari",
                                         style: .default,
                                         handler: { [weak self] (_) in
            self?.openInSafari(self?.url)
        })
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        actionController.addAction(downloadAction)
        actionController.addAction(safariAction)
        actionController.addAction(cancelAction)
    }
}

// MARK: Selector actions

extension WebController {
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc func loadWebview() {
        shouldLoad = true
        loadURL(urlOpt: url)
    }

    @objc func dismissWebController() {
        dismissWebView()
    }

    @objc func presentDownloadOption() {
        actionController.popoverPresentationController?.barButtonItem = interactionButton
        actionController.popoverPresentationController?.sourceView = view
        present(actionController, animated: true, completion: nil)
    }
}

extension WebController: Rotatable {}

extension WebController: NavigationAnimatable {
    func animationControllerForPop(to controller: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if edgeInteractionController.edge?.state == .began {
            return SystemPopAnimator(duration: 0.5, interactionController: edgeInteractionController)
        }
        return nil
    }

    func animationControllerForPush(to controller: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}