import UIKit
import WebKit
import PDFKit
import UniformTypeIdentifiers

/// Native counterparts to the Mac's built-in browser, news, video and presentation windows.
final class TTMobileBrowser: UIViewController, WKNavigationDelegate, UIDocumentPickerDelegate {
    static var sessions: [String: TTMobileBrowser] = [:]
    let webView = WKWebView()
    let pdfView = PDFView()
    let thumbnails = PDFThumbnailView()
    let modeName: String
    private var urlKey: String { "TT:portable:\(modeName):url" }

    init(modeName: String) {
        self.modeName = modeName
        super.init(nibName: nil, bundle: nil)
        title = modeName == "News" ? "NewsBlur" : modeName
    }
    required init?(coder: NSCoder) { fatalError("Use init(modeName:)") }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        thumbnails.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addSubview(pdfView)
        view.addSubview(thumbnails)
        for child in [webView, pdfView] as [UIView] {
            NSLayoutConstraint.activate([
                child.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                child.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                child.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                child.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        NSLayoutConstraint.activate([
            thumbnails.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thumbnails.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thumbnails.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            thumbnails.heightAnchor.constraint(equalToConstant: 100)
        ])
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.isHidden = true
        thumbnails.pdfView = pdfView
        thumbnails.layoutMode = .horizontal
        thumbnails.isHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: modeName == "Presentation" ? "Open" : "Address", style: .plain, target: self, action: #selector(open))
        if let saved = UserDefaults.standard.string(forKey: urlKey), let url = URL(string: saved) {
            webView.load(URLRequest(url: url))
        } else if modeName == "News" {
            webView.load(URLRequest(url: URL(string: "https://newsblur.com")!))
        }
    }
    @objc private func close() { dismiss(animated: true) }
    @objc func open() {
        if modeName == "Presentation" {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let alert = UIAlertController(title: "Open \(modeName == "Video" ? "video" : "website")", message: "Enter an http:// or https:// address.", preferredStyle: .alert)
            alert.addTextField { field in
                field.keyboardType = .URL
                field.autocapitalizationType = .none
                field.text = UserDefaults.standard.string(forKey: self.urlKey)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open", style: .default) { _ in
                guard let value = alert.textFields?.first?.text, let url = URL(string: value), ["http", "https"].contains(url.scheme ?? "") else { return }
                UserDefaults.standard.set(value, forKey: self.urlKey)
                self.webView.load(URLRequest(url: url))
            })
            present(alert, animated: true)
        }
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, let document = PDFDocument(url: url) else { return }
        pdfView.document = document
        pdfView.isHidden = false
        webView.isHidden = true
    }
    static func run(mode: String, action: String) {
        DispatchQueue.main.async {
            let session = sessions[mode] ?? TTMobileBrowser(modeName: mode)
            sessions[mode] = session
            if session.presentingViewController == nil && session.navigationController?.presentingViewController == nil {
                var presenter: UIViewController = appDelegate().mainViewController
                while let presented = presenter.presentedViewController { presenter = presented }
                let nav = UINavigationController(rootViewController: session)
                nav.modalPresentationStyle = .fullScreen
                presenter.present(nav, animated: true) {
                    if session.webView.url == nil && session.pdfView.document == nil { session.open() }
                }
            } else { session.performAction(action) }
        }
    }
    func performAction(_ action: String) {
        switch action {
        case "VolumeUp": TTModeMusicSession.shared.volume(adjustment: .up)
        case "VolumeDown": TTModeMusicSession.shared.volume(adjustment: .down)
        case "NextSlide": pdfView.goToNextPage(nil)
        case "PreviousSlide": pdfView.goToPreviousPage(nil)
        case "ToggleSlides": thumbnails.isHidden.toggle()
        case "Play", "FullScreen": navigationController?.setNavigationBarHidden(!(navigationController?.isNavigationBarHidden ?? false), animated: true)
        case "ScrollUp": webView.scrollView.setContentOffset(CGPoint(x: 0, y: max(0, webView.scrollView.contentOffset.y - webView.bounds.height * 0.7)), animated: true)
        case "ScrollDown": webView.scrollView.setContentOffset(CGPoint(x: 0, y: min(max(0, webView.scrollView.contentSize.height - webView.bounds.height), webView.scrollView.contentOffset.y + webView.bounds.height * 0.7)), animated: true)
        case "Menu": open()
        case "Next": webView.evaluateJavaScript("document.activeElement?.click()")
        case "NextStory", "PreviousStory", "NextSite", "PreviousSite":
            let key = ["NextStory":"j", "PreviousStory":"k", "NextSite":"J", "PreviousSite":"K"][action]!
            let code = key.lowercased() == "j" ? 74 : 75
            webView.evaluateJavaScript("document.dispatchEvent(new KeyboardEvent('keydown', {key:'\(key)', keyCode:\(code), which:\(code), shiftKey:\(key == key.uppercased()), bubbles:true}))")
        case "Pause": webView.evaluateJavaScript("document.querySelectorAll('video,audio').forEach(v => v.paused ? v.play() : v.pause())")
        case "FF": webView.evaluateJavaScript("document.querySelectorAll('video,audio').forEach(v => v.currentTime += 10)")
        case "Rewind": webView.evaluateJavaScript("document.querySelectorAll('video,audio').forEach(v => v.currentTime = Math.max(0, v.currentTime - 10))")
        default: break
        }
    }
}

class TTMobileBrowserOptions: TTOptionsDetailViewController {
    override func loadView() {
        let container = UIView()
        let button = UIButton(type: .system)
        button.setTitle("Open \(type(of: mode).title())", for: .normal)
        button.titleLabel?.font = UIFont(name: "Effra", size: 16)
        button.addTarget(self, action: #selector(openBrowser), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)
        NSLayoutConstraint.activate([container.heightAnchor.constraint(equalToConstant: 70), button.centerXAnchor.constraint(equalTo: container.centerXAnchor), button.centerYAnchor.constraint(equalTo: container.centerYAnchor)])
        view = container
    }
    @objc private func openBrowser() { TTMobileBrowser.run(mode: mode.nameOfClass.replacingOccurrences(of: "TTMode", with: ""), action: "Open") }
}
class TTModeWebOptions: TTMobileBrowserOptions {}
class TTModeNewsOptions: TTMobileBrowserOptions {}
class TTModeVideoOptions: TTMobileBrowserOptions {}
class TTModePresentationOptions: TTMobileBrowserOptions {}
