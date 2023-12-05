//
//  ViewController.swift
//  SSLPinningWebView
//
//  Created by SomnicsAndrew on 2023/12/5.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var mWebView: WKWebView!
    private var targetHost: String {
        return targetHost2
    }
    private let targetHost1 = "https://www.google.com"
    private let targetHost2 = "https://medium.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        testURLSessionTask(urlString: targetHost)

        showWebPage(urlString: targetHost)
    }

    private func showWebPage(urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            mWebView.load(request)
            mWebView.navigationDelegate = self
        }
    }

    private func testURLSessionTask(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let session = URLSession(configuration: .default, delegate: SSLPinningManager(), delegateQueue: nil)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Response success!!")
            } else {
                print("Response fail :(")
            }
        }
        task.resume()
    }
}

// Implement WKNavigationDelegate methods
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let authMethod = challenge.protectionSpace.authenticationMethod
        let host = challenge.protectionSpace.host
        guard authMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            host == URL(string: targetHost)?.host else {
                return completionHandler(.performDefaultHandling, nil)
        }

        if SSLPinningManager().isValid(serverTrust: serverTrust) {
            let credential: URLCredential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            print(challenge.protectionSpace)
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
                        
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Page load started")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page load finished")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Page load failed with error: \(error.localizedDescription)")
    }
}
