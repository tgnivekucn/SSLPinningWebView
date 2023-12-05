//
//  SSLPinningManager.swift
//  SSLPinningWebView
//
//  Created by SomnicsAndrew on 2023/12/5.
//


import Foundation

class SSLPinningManager: NSObject, URLSessionDelegate {
    private var pinnedCertificates: [Data] = []

    override init() {
        super.init()
        if let googleCertificate = getLocalGoogleCertificate() {
            self.pinnedCertificates.append(googleCertificate)
        }
        
        if let mediumCertificate = getLocalMediumCertificate() {
            self.pinnedCertificates.append(mediumCertificate)
        }
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if isValid(serverTrust: serverTrust) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    func isValid(serverTrust: SecTrust) -> Bool {
        let policy = SecPolicyCreateSSL(true, nil)
        SecTrustSetPolicies(serverTrust, policy)
        
        var error: CFError?
        let result = SecTrustEvaluateWithError(serverTrust, &error)
        
        guard result else { return false }

        guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else { return false }
        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data

        return pinnedCertificates.contains(serverCertificateData)
    }

    private func getLocalGoogleCertificate() -> Data? {
        if let url = Bundle.main.url(forResource: "_.google.com", withExtension: "cer") {
            print("url is: \(url.absoluteString)")
            if let certData = try? Data(contentsOf: url) {
                return certData
            }
        }
        return nil
    }

    private func getLocalMediumCertificate() -> Data? {
        if let url = Bundle.main.url(forResource: "medium.com", withExtension: "cer") {
            print("url is: \(url.absoluteString)")
            if let certData = try? Data(contentsOf: url) {
                return certData
            }
        }
        return nil
    }
}
