
import UIKit
import WebKit

///  A view controller containing a webview allowing users to login to CAS and Sakai
class LoginViewController: WebController {
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    /// Loads Login URL for CAS Authentication
    override func viewDidLoad() {
        super.viewDidLoad()
        RequestManager.shared.resetCache()
        let myURL = URL(string: AppGlobals.LOGIN_URL)
        loadURL(urlOpt: myURL!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Captures HTTP Cookies from specific URLs and loads them into Alamofire Session, allowing all future requests to be authenticated.
    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if webView.url!.absoluteString == AppGlobals.COOKIE_URL_1 || webView.url!.absoluteString == AppGlobals.COOKIE_URL_2 {
            let store = WKWebsiteDataStore.default().httpCookieStore
            store.getAllCookies { (cookies) in
                for cookie in cookies {
                    //print(cookie)
                    HTTPCookieStorage.shared.setCookie(cookie as HTTPCookie)
                    RequestManager.shared.addCookie(cookie: cookie)
                }
            }
        }
        decisionHandler(.allow)
        return
    }
    
    /// Captures all HTTP headers and loads them into Alamofire Session, for request authentication.
    /// Stops webview navigation and forces controller transition once target URL is reaches
    override func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response as? HTTPURLResponse
        let headers = response!.allHeaderFields
        for header in headers {
            RequestManager.shared.addHeader(value: header.value, key: header.key)
        }
        if(webView.url!.absoluteString == AppGlobals.COOKIE_URL_2) {
            decisionHandler(.cancel)
            RequestManager.shared.loggedIn = true
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        } else {
            decisionHandler(.allow)
        }
    }
}