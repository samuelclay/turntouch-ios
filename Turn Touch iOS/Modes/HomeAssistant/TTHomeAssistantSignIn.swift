import UIKit
import WebKit

/// Only Home Assistant's own page handles the user's password. The app receives an OAuth code.
final class TTHomeAssistantSignIn: UIViewController, WKNavigationDelegate {
    private let home: String
    private let state = UUID().uuidString
    private let completion: (String) -> Void
    private var completed = false
    init(home: String, completion: @escaping (String) -> Void) { self.home = home; self.completion = completion; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("Use init(home:completion:)") }
    override func loadView() {
        let config = WKWebViewConfiguration(); config.websiteDataStore = .nonPersistent()
        let web = WKWebView(frame: .zero, configuration: config); web.navigationDelegate = self; view = web
        title = TTText("Home Assistant")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        var url = URLComponents(string: home + "/auth/authorize")!
        url.queryItems = [URLQueryItem(name: "client_id", value: TTHAClientID), URLQueryItem(name: "redirect_uri", value: TTHARedirectURI), URLQueryItem(name: "state", value: state)]
        web.load(URLRequest(url: url.url!))
    }
    @objc private func cancel() { dismiss(animated: true) }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let parts = URLComponents(url: url, resolvingAgainstBaseURL: false) else { decisionHandler(.cancel); return }
        if parts.scheme == "https", parts.host == "turntouch.com", parts.path == "/home-assistant/callback", parts.port == nil, parts.user == nil, parts.password == nil {
            decisionHandler(.cancel)
            let values = parts.queryItems ?? []
            guard !completed, values.filter({ $0.name == "state" }).count == 1, values.first(where: { $0.name == "state" })?.value == state,
                  let code = values.first(where: { $0.name == "code" })?.value, !code.isEmpty else { return }
            completed = true; dismiss(animated: true) { self.completion(code) }
            return
        }
        decisionHandler(["http", "https"].contains(parts.scheme ?? "") ? .allow : .cancel)
    }
}
