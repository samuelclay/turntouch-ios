import UIKit

@objcMembers
class TTModeHomeAssistant: TTMode {
    override class func title() -> String { return TTText("Home Assistant") }
    override class func subtitle() -> String { return TTText("Your home, scenes, and automations") }
    override class func imageName() -> String { return "mode_home.png" }
    override class func actions() -> [String] { return ["TTModeHomeAssistantAction"] }
    override func defaultNorth() -> String { return "TTModeHomeAssistantAction" }
    override func defaultEast() -> String { return "TTModeHomeAssistantAction" }
    override func defaultWest() -> String { return "TTModeHomeAssistantAction" }
    override func defaultSouth() -> String { return "TTModeHomeAssistantAction" }
    func titleTTModeHomeAssistantAction() -> String { (action?.optionValue("homeAssistantBinding") as? [String: String])?["name"] ?? TTText("Home Assistant action") }
    func imageTTModeHomeAssistantAction() -> String { return "mode_home.png" }
    override func titleInDirection(_ direction: TTModeDirection, buttonMoment: TTButtonMoment) -> String {
        let binding = action?.batchActionKey != nil ? action?.optionValue("homeAssistantBinding") : actionOptionValue("homeAssistantBinding", actionName: "TTModeHomeAssistantAction", direction: direction)
        return (binding as? [String: String])?["name"] ?? TTText("Home Assistant action")
    }
    func runTTModeHomeAssistantAction() {
        guard let binding = action?.optionValue("homeAssistantBinding") as? [String: String],
              let entity = binding["entity_id"], let service = binding["service"],
              binding["server_url"] == TTHomeAssistantClient.shared().serverURL else { return }
        TTHomeAssistantClient.shared().callAction(service, entity: entity, data: binding["data"] ?? "{}") { _, error in
            if let error = error { NSLog("Home Assistant: %@", error.localizedDescription) }
        }
    }
}

class TTModeHomeAssistantOptions: TTOptionsDetailViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, NetServiceBrowserDelegate, NetServiceDelegate {
    var client = TTHomeAssistantClient.shared()
    private let blue = UIColor(red: 0.22, green: 0.49, blue: 0.70, alpha: 1)
    private let ink = UIColor(red: 0.25, green: 0.29, blue: 0.38, alpha: 1)
    private let stack = UIStackView()
    private let search = UITextField()
    private let filter = UIButton(type: .system)
    private let menu = UIButton(type: .system)
    private let table = UITableView(frame: .zero, style: .plain)
    private let connection = UIStackView()
    private let address = UITextField()
    private let token = UITextField()
    private let connect = UIButton(type: .system)
    private let settings = UIStackView()
    private let disclosure = UIButton(type: .system)
    private let servicePicker = UIButton(type: .system)
    private let advanced = UIStackView()
    private let dataDisclosure = UIButton(type: .system)
    private let editor = UITextView()
    private let help = UILabel()
    private let test = UIButton(type: .system)
    private let save = UIButton(type: .system)
    private let status = UILabel()
    private let empty = UILabel()
    private var observer: NSObjectProtocol?
    private var entityID = ""
    private var serviceID = ""
    private var category = ""
    private var visible: [[String: Any]] = []
    private var actions: [[String: Any]] = []
    private var destination = ""
    private var busy = false
    private var loaded = false
    private let browser = NetServiceBrowser()
    private var services: [NetService] = []
    private var height: NSLayoutConstraint?
    private var categories: [(String, String)] { [("", TTText("Controllable entities")), ("*", TTText("All entities")), ("light", TTText("Lights")), ("switch", TTText("Switches")), ("scene", TTText("Scenes")), ("script", TTText("Scripts")), ("automation", TTText("Automations")), ("cover", TTText("Covers")), ("media_player", TTText("Media players")), ("climate", TTText("Climate")), ("other", TTText("Other"))] }
    private var entity: [String: Any]? { client.entities.first { $0["entity_id"] as? String == entityID } as? [String: Any] }
    private func name(_ entity: [String: Any]) -> String { (entity["attributes"] as? [String: Any])?["friendly_name"] as? String ?? entity["entity_id"] as? String ?? "" }
    private func font(_ size: CGFloat) -> UIFont { UIFont(name: "Effra", size: size) ?? .systemFont(ofSize: size) }
    private func label(_ text: String, size: CGFloat = 13) -> UILabel { let l = UILabel(); l.text = text; l.font = font(size); l.textColor = .secondaryLabel; l.numberOfLines = 0; return l }
    private func column(_ views: [UIView]) -> UIStackView { let s = UIStackView(arrangedSubviews: views); s.axis = .vertical; s.spacing = 8; return s }
    private func button(_ b: UIButton, _ title: String, _ selector: Selector, primary: Bool = false) {
        b.setTitle(title, for: .normal); b.titleLabel?.font = font(15); b.titleLabel?.numberOfLines = 0; b.titleLabel?.textAlignment = .center
        b.addTarget(self, action: selector, for: .touchUpInside); b.tintColor = primary ? .white : ink
        b.backgroundColor = primary ? blue : UIColor(white: 0.95, alpha: 1); b.layer.cornerRadius = 8
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        b.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
    private func field(_ f: UITextField, _ placeholder: String) {
        f.placeholder = placeholder; f.font = font(15); f.borderStyle = .roundedRect; f.autocorrectionType = .no; f.autocapitalizationType = .none
        f.heightAnchor.constraint(equalToConstant: 42).isActive = true
    }
    override func loadView() {
        view = UIView(); view.backgroundColor = .white
        stack.axis = .vertical; stack.spacing = 8; stack.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(stack)
        NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 12), stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12), stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)])
        field(search, TTText("Search Home Assistant")); search.addTarget(self, action: #selector(filterChanged), for: .editingChanged); search.accessibilityIdentifier = "ha-search"
        button(filter, TTText("Controllable entities"), #selector(noop)); filter.backgroundColor = .clear; filter.showsMenuAsPrimaryAction = true
        filter.menu = UIMenu(children: categories.map { id, title in UIAction(title: title) { [weak self] _ in self?.category = id; self?.filter.setTitle(title + " ▾", for: .normal); self?.filterChanged() } })
        menu.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal); menu.tintColor = .secondaryLabel; menu.accessibilityLabel = TTText("Home Assistant menu"); menu.widthAnchor.constraint(equalToConstant: 44).isActive = true; menu.showsMenuAsPrimaryAction = true
        let toolbar = UIStackView(arrangedSubviews: [filter, menu]); toolbar.spacing = 8
        field(address, TTText("Home Assistant address")); address.keyboardType = .URL; address.text = client.serverURL.isEmpty ? "http://homeassistant.local:8123" : client.serverURL
        field(token, TTText("Access token")); token.isSecureTextEntry = true; token.isHidden = true
        button(connect, TTText("Sign in…"), #selector(connectPressed), primary: true)
        connection.axis = .vertical; connection.spacing = 8; [address, token, connect].forEach(connection.addArrangedSubview); connection.isHidden = true
        table.dataSource = self; table.delegate = self; table.rowHeight = 56; table.backgroundColor = .white; table.layer.borderWidth = 0.5; table.layer.borderColor = UIColor.separator.cgColor; table.layer.cornerRadius = 8
        table.heightAnchor.constraint(equalToConstant: 210).isActive = true; table.tableFooterView = UIView(); table.keyboardDismissMode = .onDrag
        empty.font = font(14); empty.textColor = .secondaryLabel; empty.numberOfLines = 0; empty.textAlignment = .center
        button(disclosure, TTText("Action settings") + "  ›", #selector(toggleSettings)); disclosure.backgroundColor = .clear; disclosure.accessibilityLabel = TTText("Action settings")
        button(servicePicker, "", #selector(noop)); servicePicker.showsMenuAsPrimaryAction = true
        button(dataDisclosure, TTText("Action data (optional JSON)") + "  ›", #selector(toggleData)); dataDisclosure.backgroundColor = .clear; dataDisclosure.accessibilityLabel = TTText("Action data (optional JSON)")
        help.font = font(12); help.numberOfLines = 0; help.textColor = .secondaryLabel
        editor.font = .monospacedSystemFont(ofSize: 13, weight: .regular); editor.layer.cornerRadius = 6; editor.layer.borderWidth = 0.5; editor.layer.borderColor = UIColor.separator.cgColor; editor.heightAnchor.constraint(equalToConstant: 100).isActive = true; editor.delegate = self; editor.autocorrectionType = .no; editor.autocapitalizationType = .none
        advanced.axis = .vertical; advanced.spacing = 8; [help, editor].forEach(advanced.addArrangedSubview); advanced.isHidden = true
        settings.axis = .vertical; settings.spacing = 8; [label(TTText("Choose what the remote button does in Home Assistant.")), servicePicker, dataDisclosure, advanced].forEach(settings.addArrangedSubview); settings.isHidden = true
        button(test, TTText("Test action"), #selector(testPressed)); test.accessibilityIdentifier = "ha-test"
        button(save, TTText("Set remote button"), #selector(savePressed), primary: true); save.accessibilityIdentifier = "ha-save"
        status.font = font(13); status.numberOfLines = 0; status.textAlignment = .center; status.isHidden = true
        [search, toolbar, connection, table, disclosure, settings, test].forEach(stack.addArrangedSubview)
        if let action = action {
            let direction: String
            switch action.direction { case .north: direction = TTText("North"); case .east: direction = TTText("East"); case .west: direction = TTText("West"); case .south: direction = TTText("South"); default: direction = "" }
            let gesture: String
            switch action.mode.modeDirection { case .single: gesture = TTText("Single tap"); case .double: gesture = TTText("Double tap"); case .hold: gesture = TTText("hold"); default: gesture = type(of: action.mode).title() }
            destination = direction + " · " + gesture
            let line = UIView(); line.backgroundColor = .separator; line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            let target = label(destination, size: 12); target.textAlignment = .center
            [line, target, save].forEach(stack.addArrangedSubview)
        }
        stack.addArrangedSubview(status)
        let binding = action?.optionValue("homeAssistantBinding") as? [String: String] ?? [:]
        entityID = binding["entity_id"] ?? ""; serviceID = binding["service"] ?? ""; editor.text = binding["data"] ?? "{}"
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(TTHAConnectionChanged), object: client, queue: .main) { [weak self] _ in self?.update(); self?.initialRefresh() }
        browser.delegate = self
        update(); initialRefresh()
    }
    deinit { if let observer = observer { NotificationCenter.default.removeObserver(observer) }; browser.stop() }
    override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews(); appDelegate().mainViewController.adjustOptionsHeight(view) }
    private func initialRefresh() { if client.connected && !loaded { loaded = true; refresh() } }
    private func show(_ text: String, error: Bool = false) { status.text = text; status.textColor = error ? .systemRed : blue; status.isHidden = text.isEmpty; view.setNeedsLayout() }
    private func complete(_ error: Error?) { busy = false; update(); if let error = error { show(error.localizedDescription, error: true) } }
    private func refresh() { busy = true; update(); client.refreshCatalog { [weak self] _, error in self?.complete(error) } }
    @objc private func noop() {}
    @objc private func filterChanged() {
        visible = (client.entities as? [[String: Any]] ?? []).filter { item in
            let id = item["entity_id"] as? String ?? ""; let domain = id.components(separatedBy: ".").first ?? ""
            let matches: Bool
            switch category { case "": matches = !TTHomeAssistantClient.actions(forEntity: item, services: client.services).isEmpty; case "*": matches = true; case "other": matches = !categories.contains { $0.0 == domain }; default: matches = domain == category }
            let content = [name(item), id, item["tt_area"] as? String ?? "", item["tt_device"] as? String ?? ""].joined(separator: " ")
            return matches && ((search.text ?? "").isEmpty || content.range(of: search.text ?? "", options: [.caseInsensitive, .diacriticInsensitive]) != nil)
        }
        empty.text = client.connected ? TTText("No matching entities") : TTText("Connect using the Home Assistant menu.")
        table.backgroundView = visible.isEmpty ? empty : nil; table.reloadData()
    }
    private func update() {
        filterChanged()
        actions = entity.map { TTHomeAssistantClient.actions(forEntity: $0, services: client.services) as? [[String: Any]] ?? [] } ?? []
        let selected = actions.first { $0["id"] as? String == serviceID }
        disclosure.isHidden = entity == nil; if entity == nil { settings.isHidden = true }
        servicePicker.setTitle(selected?["name"] as? String ?? TTText("This entity has no callable actions. Sensors are usually read-only."), for: .normal)
        servicePicker.menu = UIMenu(children: actions.map { item in UIAction(title: item["name"] as? String ?? "") { [weak self] _ in self?.serviceID = item["id"] as? String ?? ""; self?.show(""); self?.update() } })
        let metadata = selected?["metadata"] as? [String: Any] ?? [:]
        let fields = metadata["fields"] as? [String: [String: Any]] ?? [:]
        let required = fields.filter { $0.value["required"] as? Bool == true && $0.key != "entity_id" }.map { $0.key }.sorted()
        help.text = (metadata["description"] as? String ?? "") + "\n" + (required.isEmpty ? TTText("No required action data.") : TTText("Required data: ") + required.joined(separator: ", "))
        test.isEnabled = selected != nil && client.connected && !busy; save.isEnabled = test.isEnabled; save.alpha = save.isEnabled ? 1 : 0.4
        menu.menu = UIMenu(children: [
            UIAction(title: TTText("Connection…")) { [weak self] _ in self?.toggleConnection() },
            UIAction(title: TTText("Sign in…")) { [weak self] _ in self?.showConnection(token: false) },
            UIAction(title: TTText("Use access token…")) { [weak self] _ in self?.showConnection(token: true) },
            UIAction(title: TTText("Open token settings")) { [weak self] _ in if let url = TTHomeAssistantClient.normalizedURL(self?.address.text ?? ""), let settings = URL(string: url + "/profile/security") { UIApplication.shared.open(settings) } },
            UIAction(title: TTText("Refresh"), attributes: client.connected && !busy ? [] : .disabled) { [weak self] _ in self?.refresh() },
            UIAction(title: TTText("Disconnect"), attributes: client.connected ? .destructive : .disabled) { [weak self] _ in self?.client.disconnect(); self?.loaded = false; self?.entityID = ""; self?.serviceID = ""; self?.show(""); self?.update() }
        ])
        view.setNeedsLayout()
    }
    @objc private func toggleSettings() { settings.isHidden.toggle(); disclosure.setTitle(TTText("Action settings") + (settings.isHidden ? "  ›" : "  ⌄"), for: .normal); view.setNeedsLayout() }
    @objc private func toggleData() { advanced.isHidden.toggle(); dataDisclosure.setTitle(TTText("Action data (optional JSON)") + (advanced.isHidden ? "  ›" : "  ⌄"), for: .normal); view.setNeedsLayout() }
    private func toggleConnection() { connection.isHidden.toggle(); if !connection.isHidden { discover() }; view.setNeedsLayout() }
    private func showConnection(token: Bool) { connection.isHidden = false; self.token.isHidden = !token; connect.setTitle(token ? TTText("Connect") : TTText("Sign in…"), for: .normal); discover(); view.setNeedsLayout() }
    private func discover() { browser.stop(); browser.searchForServices(ofType: "_home-assistant._tcp.", inDomain: "local.") }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) { services.append(service); service.delegate = self; service.resolve(withTimeout: 5) }
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let host = sender.hostName else { return }
        let url = "http://\(host):\(sender.port)"
        guard !connection.arrangedSubviews.contains(where: { $0.accessibilityIdentifier == url }) else { return }
        let choice = UIButton(type: .system); choice.setTitle(sender.name, for: .normal); choice.titleLabel?.font = font(14); choice.accessibilityIdentifier = url
        choice.addAction(UIAction { [weak self] _ in self?.address.text = url }, for: .touchUpInside); connection.insertArrangedSubview(choice, at: 1)
    }
    @objc private func connectPressed() {
        view.endEditing(true)
        guard let home = TTHomeAssistantClient.normalizedURL(address.text ?? "") else { show(TTText("Enter an http:// or https:// address."), error: true); return }
        if !token.isHidden {
            busy = true; update(); client.connect(toURL: home, token: token.text ?? "") { [weak self] _, error in self?.complete(error); if error == nil { self?.token.text = ""; self?.connection.isHidden = true; self?.loaded = true } }
        } else {
            let login = TTHomeAssistantSignIn(home: home) { [weak self] code in
                guard let self = self else { return }; self.busy = true; self.update()
                self.client.exchangeCode(code, serverURL: home) { [weak self] _, error in self?.complete(error); if error == nil { self?.connection.isHidden = true; self?.loaded = true } }
            }
            var presenter: UIViewController = appDelegate().mainViewController
            while let presented = presenter.presentedViewController { presenter = presented }
            presenter.present(UINavigationController(rootViewController: login), animated: true)
        }
    }
    private func binding() throws -> [String: String] {
        guard let entity = entity, let action = actions.first(where: { $0["id"] as? String == serviceID }) else { throw NSError(domain: "HomeAssistant", code: 1, userInfo: [NSLocalizedDescriptionKey: TTText("Choose an entity first.")]) }
        let body = try TTHomeAssistantClient.serviceBody(forEntity: entityID, data: editor.text)
        let fields = (action["metadata"] as? [String: Any])?["fields"] as? [String: [String: Any]] ?? [:]
        for (key, field) in fields where field["required"] as? Bool == true && body[key] == nil && field["default"] == nil {
            throw NSError(domain: "HomeAssistant", code: 2, userInfo: [NSLocalizedDescriptionKey: TTText("Add the required action data field: ") + key])
        }
        return ["entity_id": entityID, "service": serviceID, "data": editor.text, "name": name(entity), "server_url": client.serverURL]
    }
    @objc private func testPressed() {
        do { let value = try binding(); busy = true; update(); show(TTText("Running action…")); client.callAction(value["service"]!, entity: value["entity_id"]!, data: value["data"]!) { [weak self] _, error in self?.complete(error); if error == nil { self?.show(TTText("Home Assistant accepted the action.")) } } }
        catch { settings.isHidden = false; advanced.isHidden = false; show(error.localizedDescription, error: true) }
    }
    @objc private func savePressed() {
        do { let value = try binding(); if let action = action, let key = action.batchActionKey {
                action.mode.changeBatchActionOption(key, optionName: "homeAssistantBinding", to: value, direction: action.mode.modeDirection, actionDirection: action.direction)
            } else { action?.changeActionOption("homeAssistantBinding", to: value) }; show("✓ " + TTText("{0} now runs “{1}”.", destination, value["name"]!)); appDelegate().mainViewController.view.setNeedsDisplay() }
        catch { settings.isHidden = false; advanced.isHidden = false; show(error.localizedDescription, error: true) }
    }
    func textViewDidChange(_ textView: UITextView) { show("") }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { visible.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = visible[indexPath.row]; let id = item["entity_id"] as? String ?? ""; let domain = id.components(separatedBy: ".").first ?? ""
        let cell = tableView.dequeueReusableCell(withIdentifier: "entity") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "entity")
        cell.textLabel?.text = name(item); cell.textLabel?.font = font(14); cell.textLabel?.textColor = ink; cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = [item["tt_area"] as? String ?? "", categories.first { $0.0 == domain }?.1 ?? TTText("Other")].filter { !$0.isEmpty }.joined(separator: " · ")
        cell.detailTextLabel?.font = font(12); cell.detailTextLabel?.textColor = .secondaryLabel
        cell.imageView?.image = UIImage(systemName: ["light": "lightbulb", "switch": "powerplug", "scene": "sparkles", "script": "play.rectangle", "automation": "gearshape.2", "cover": "window.vertical.closed", "media_player": "speaker.wave.2", "climate": "thermometer"][domain] ?? "house")
        cell.tintColor = blue; cell.accessoryType = id == entityID ? .checkmark : .none; cell.backgroundColor = id == entityID ? blue.withAlphaComponent(0.08) : .white
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        entityID = visible[indexPath.row]["entity_id"] as? String ?? ""; serviceID = TTHomeAssistantClient.actions(forEntity: visible[indexPath.row], services: client.services).first?["id"] as? String ?? ""; editor.text = "{}"; show(""); update()
    }
}
class TTModeHomeAssistantActionOptions: TTModeHomeAssistantOptions {}

#if DEBUG
/// Isolated UI-test destination. Never uses the user's connection or remote assignments.
final class TTHomeAssistantTestHost: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let options = TTModeHomeAssistantActionOptions(nibName: nil, bundle: nil)
        let action = TTAction(batchActionKey: "TTModeHomeAssistant:TTModeHomeAssistantAction:ui-fixture", direction: .north)
        action.mode.modeDirection = ProcessInfo.processInfo.arguments.contains("--ha-ui-sixteen") ? .north : .single
        options.mode = action.mode; options.action = action
        options.client = TTHomeAssistantClient(storageIdentifier: "com.turntouch.homeassistant.ui-tests")
        if ProcessInfo.processInfo.arguments.contains("--ha-ui-preview"), let home = ProcessInfo.processInfo.environment["HA_TEST_URL"] {
            let binding = ["entity_id": "scene.evening", "service": "scene.turn_on", "data": "{}", "name": "Evening", "server_url": home]
            action.mode.changeBatchActionOption(action.batchActionKey!, optionName: "homeAssistantBinding", to: binding, direction: action.mode.modeDirection, actionDirection: .north)
            options.client.connect(toURL: home, token: "fixture-token") { _, _ in }
        }
        let scroll = UIScrollView(); scroll.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(scroll)
        addChild(options); options.view.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(options.view); options.didMove(toParent: self)
        NSLayoutConstraint.activate([scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor), options.view.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), options.view.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor), options.view.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), options.view.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor), options.view.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)])
    }
}
#endif
