import UIKit

/// English keys identify application UI only; never pass device names or protocol values.
func TTText(_ source: String, _ arguments: Any...) -> String {
    var result = TTLocalization.bundle.localizedString(forKey: source, value: source, table: "Localizable")
    // Replace in one pass so a user's value containing {0} is never treated as a template.
    let expression = try! NSRegularExpression(pattern: #"\{(\d+)\}"#)
    for match in expression.matches(in: result, range: NSRange(result.startIndex..., in: result)).reversed() {
        guard let indexRange = Range(match.range(at: 1), in: result), let index = Int(result[indexRange]),
              arguments.indices.contains(index), let range = Range(match.range, in: result) else { continue }
        result.replaceSubrange(range, with: String(describing: arguments[index]))
    }
    return result
}

enum TTLocalization {
    static let key = "TT:language"
    static let languages: [(String, String)] = {
        let url = Bundle.main.url(forResource: "languages", withExtension: "json", subdirectory: "Localization")!
        let names = try! JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: String]
        return names.sorted { ($0.key == "en" && $1.key != "en") || ($0.key != "en" && $1.key != "en" && $0.value.localizedStandardCompare($1.value) == .orderedAscending) }
    }()
    static var selection: String { UserDefaults.standard.string(forKey: key) ?? "auto" }
    static func resolve(_ preferred: [String]) -> String {
        for tag in preferred {
            let locale = Locale(identifier: tag)
            let language = locale.languageCode ?? ""
            if language == "zh" { return locale.scriptCode == "Hant" || ["TW", "HK", "MO"].contains(locale.regionCode ?? "") ? "zh-Hant" : "zh-Hans" }
            if language == "pt" { return "pt-BR" }
            if languages.contains(where: { $0.0 == tag }) { return tag }
            if languages.contains(where: { $0.0 == language }) { return language }
        }
        return "en"
    }
    static let code = resolve(selection == "auto" ? Locale.preferredLanguages : [selection])
    static let bundle = Bundle(path: Bundle.main.path(forResource: code, ofType: "lproj") ?? "") ?? Bundle.main
    static var needsWelcome: Bool { !UserDefaults.standard.bool(forKey: "TT:language:welcomed") }
    static var displayName: String { selection == "auto" ? TTText("Automatic (device language)") : languages.first { $0.0 == selection }?.1 ?? "English" }
    static func choose(_ language: String) {
        let prefs = UserDefaults.standard
        prefs.set(language, forKey: key)
        prefs.set(true, forKey: "TT:language:welcomed")
        if language == "auto" { prefs.removeObject(forKey: "AppleLanguages") }
        else { prefs.set([language], forKey: "AppleLanguages") }
    }
    static func present(from parent: UIViewController, firstLaunch: Bool = false, completion: (() -> Void)? = nil) {
        let picker = TTLanguageViewController()
        picker.firstLaunch = firstLaunch
        picker.completion = completion
        let navigation = UINavigationController(rootViewController: picker)
        navigation.modalPresentationStyle = .formSheet
        navigation.isModalInPresentation = firstLaunch
        parent.present(navigation, animated: true)
    }
}

private final class TTLanguageViewController: UITableViewController {
    var firstLaunch = false
    var completion: (() -> Void)?
    private var selected = TTLocalization.selection
    private var choices: [(String, String)] { [("auto", TTText("Automatic (device language)"))] + TTLocalization.languages }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TTText("Language")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 48
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TTText("Continue"), style: .done, target: self, action: #selector(save))
        if !firstLaunch { navigationItem.leftBarButtonItem = UIBarButtonItem(title: TTText("Cancel"), style: .plain, target: self, action: #selector(cancel)) }
    }
    private var introduction: String {
        TTText(firstLaunch ? "Welcome to Turn Touch" : "Choose your language") + "\n\n" +
        TTText("You can change this anytime in Settings. Language changes apply the next time you launch Turn Touch.")
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let size = (introduction as NSString).boundingRect(with: CGSize(width: tableView.bounds.width - 40, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil)
        return ceil(size.height) + 32
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        let label = UILabel()
        label.text = introduction
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        return container
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { choices.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = choices[indexPath.row].1
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = selected == choices[indexPath.row].0 ? .checkmark : .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = choices[indexPath.row].0
        tableView.reloadData()
    }
    @objc private func save() {
        TTLocalization.choose(selected)
        dismiss(animated: true, completion: completion)
    }
    @objc private func cancel() { dismiss(animated: true) }
}
