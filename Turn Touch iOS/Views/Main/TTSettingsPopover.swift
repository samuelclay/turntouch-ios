import UIKit

/// The same grouped, gear-anchored settings menu used by the Android app.
final class TTSettingsPopover: UIViewController {
    private let ink = UIColor(hex: 0x404A60)
    private let muted = UIColor(hex: 0x808AA0)
    private let blue = UIColor(hex: 0x007AFF)
    private let scrollView = UIScrollView()
    private let content = UIStackView()
    private var showAllApps = false
    private var needsLayoutRefresh = false
    private var remoteLabels: [(String, UILabel, UILabel)] = []
    private var remoteTimer: Timer?
    private var buttonDescription: UILabel?
    private var performDescription: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) { overrideUserInterfaceStyle = .light }
        view.backgroundColor = .white
        view.accessibilityIdentifier = "settings-popover"
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        let title = label(TTText("Settings"), size: 20, bold: true)
        let done = UIButton(type: .system)
        done.setTitle(TTText("Done"), for: .normal)
        done.titleLabel?.font = font(15)
        done.tintColor = blue
        done.addTarget(self, action: #selector(close), for: .touchUpInside)
        done.widthAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        let header = UIStackView(arrangedSubviews: [title, done])
        header.alignment = .center
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        scrollView.backgroundColor = UIColor(hex: 0xF5F6F8)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        content.axis = .vertical
        content.spacing = 24
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            header.heightAnchor.constraint(equalToConstant: 48),
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -12),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -24)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showAllApps = false
        rebuild()
        scrollView.setContentOffset(.zero, animated: false)
        remoteTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.refreshRemotes() }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        remoteTimer?.invalidate()
        remoteTimer = nil
        if needsLayoutRefresh {
            needsLayoutRefresh = false
            appDelegate().redrawMainLayout()
        }
    }

    @objc private func close() { dismiss(animated: true) }

    private func leave(_ action: @escaping () -> Void) {
        // Wait for dismissal before presenting another controller from the main screen.
        dismiss(animated: true, completion: action)
    }

    private func rebuild() {
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }
        remoteLabels.removeAll()
        let main = appDelegate().mainViewController!
        let modeMap = appDelegate().modeMap!
        let prefs = UserDefaults.standard
        let devices = appDelegate().bluetoothMonitor.foundDevices.devices
        let paired = prefs.stringArray(forKey: "TT:devices:paired") ?? []
        section(TTText("Language"), rows: [link(TTText("Language"), subtitle: TTLocalization.displayName, icon: "preferences") { [weak self] in
            self?.leave { TTLocalization.present(from: main) }
        }])
        var remoteRows: [UIView] = []
        for id in paired {
            let device = devices.first { $0.uuid == id }
            let title = label(device?.nickname ?? prefs.string(forKey: "TT:device:\(id):nickname") ?? TTText("Turn Touch"), size: 17)
            let detail = label(TTText("Disconnected"), size: 13, color: muted)
            remoteLabels.append((id, title, detail))
            remoteRows.append(link(title: title, subtitle: detail, icon: "remote_graphic") { [weak self] in
                guard let self = self else { return }
                if let row = main.deviceTitlesView.arrangedSubviews.compactMap({ $0 as? TTDeviceTitleView }).first(where: { $0.device.uuid == id }), let button = row.settingsButton {
                    self.leave { main.toggleDeviceMenu(button, deviceTitleView: row, device: row.device) }
                } else {
                    let alert = UIAlertController(title: title.text, message: TTText("Press a button on your remote to wake it. If it is connected to another device, disconnect it there first."), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: TTText("OK"), style: .default))
                    self.present(alert, animated: true)
                }
            })
        }
        remoteRows.append(link(TTText("Add a new remote"), subtitle: paired.isEmpty ? TTText("Pair your Turn Touch") : nil, icon: "add") { [weak self] in self?.leave { main.showPairingModal() } })
        section(TTText("REMOTES"), rows: remoteRows)
        refreshRemotes()

        let twelve = modeMap.buttonAppMode() == .TwelveButtons
        let description = label(twelve ? TTText("Single tap, double tap, and hold") : TTText("Hold a button to switch between four apps"), size: 14, color: muted)
        buttonDescription = description
        let segment = UISegmentedControl(items: [TTText("12 actions"), TTText("16 actions")])
        segment.accessibilityLabel = TTText("Button mode")
        segment.selectedSegmentIndex = twelve ? 0 : 1
        segment.setTitleTextAttributes([.font: font(15), .foregroundColor: ink], for: .normal)
        segment.setTitleTextAttributes([.font: font(15, bold: true), .foregroundColor: blue], for: .selected)
        segment.addTarget(self, action: #selector(changeButtonMode(_:)), for: .valueChanged)
        segment.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let modeControls = UIStackView(arrangedSubviews: [label(TTText("Button mode"), size: 17), description, segment])
        modeControls.axis = .vertical
        modeControls.spacing = 6
        modeControls.setCustomSpacing(14, after: description)

        let perform = UISwitch()
        perform.accessibilityLabel = TTText("Run actions from the screen")
        perform.onTintColor = blue
        perform.isOn = modeMap.buttonActionMode == .performActions
        perform.addTarget(self, action: #selector(changePerformMode(_:)), for: .valueChanged)
        let performDetail = label(perform.isOn ? TTText("Screen taps perform actions") : TTText("Screen taps edit your buttons"), size: 14, color: muted)
        performDescription = performDetail
        let performLabels = UIStackView(arrangedSubviews: [label(TTText("Run actions from the screen"), size: 17), performDetail])
        performLabels.axis = .vertical
        performLabels.spacing = 4
        let performRow = UIStackView(arrangedSubviews: [performLabels, perform])
        performRow.alignment = .center
        performRow.spacing = 12
        section(TTText("BUTTONS"), rows: [inset(modeControls, by: 16), inset(performRow, by: 16)])

        let favorites = ["TTModeHue", "TTModeNanoleaf", "TTModeGovee", "TTModeSonos", "TTModeKasa"]
        let names = favorites + (showAllApps ? modeMap.availableModes.filter { !favorites.contains($0) } : [])
        var appRows: [UIView] = names.compactMap { name in
            guard let type = NSClassFromString("Turn_Touch_iOS.\(name)") as? TTMode.Type,
                  NSClassFromString("Turn_Touch_iOS.\(name)Options") is TTOptionsDetailViewController.Type else { return nil }
            return link(type.title(), subtitle: favorites.contains(name) ? TTText("Set up and manage connection") : TTText("App options"), icon: type.imageName()) { [weak self] in
                self?.leave { main.showSettingsConnection(name) }
            }
        }
        let more = TTSettingsButton()
        more.setTitle(showAllApps ? TTText("Show fewer apps") : TTText("Show all apps"), for: .normal)
        more.setTitleColor(blue, for: .normal)
        more.titleLabel?.font = font(15)
        more.heightAnchor.constraint(equalToConstant: 48).isActive = true
        more.action = { [weak self] in
            guard let self = self else { return }
            let offset = self.scrollView.contentOffset
            self.showAllApps.toggle()
            self.rebuild()
            self.view.layoutIfNeeded()
            let maximum = max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height)
            self.scrollView.setContentOffset(CGPoint(x: 0, y: min(offset.y, maximum)), animated: false)
        }
        appRows.append(more)
        section(TTText("APPS & CONNECTIONS"), rows: appRows)
        section(TTText("PREFERENCES"), rows: [
            link(TTText("Sounds, vibration & privacy"), icon: "preferences") { [weak self] in self?.leave { main.showSettingsModal() } },
            link(TTText("Setup geofence"), icon: "geofence") { [weak self] in self?.leave { main.showGeofencingModal() } }
        ])
        section(TTText("HELP"), rows: [
            link(TTText("How it works"), icon: "how_it_works") { [weak self] in self?.leave { main.showFtuxModal() } },
            link(TTText("Contact support"), icon: "support") { [weak self] in self?.leave { main.showSupportModal() } },
            link(TTText("About Turn Touch"), icon: "about") { [weak self] in self?.leave { main.showAboutModal() } }
        ])
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let footer = label(TTText("Turn Touch for iOS · {0}\nOriginal design and artwork © Turn Touch", version), size: 12, color: muted)
        footer.textAlignment = .center
        content.addArrangedSubview(footer)
    }

    @objc private func changeButtonMode(_ sender: UISegmentedControl) {
        let twelve = sender.selectedSegmentIndex == 0
        appDelegate().modeMap.switchButtonAppMode(twelve ? .TwelveButtons : .SixteenButtons)
        needsLayoutRefresh = true
        buttonDescription?.text = twelve ? TTText("Single tap, double tap, and hold") : TTText("Hold a button to switch between four apps")
    }

    @objc private func changePerformMode(_ sender: UISwitch) {
        appDelegate().modeMap.switchPerformActionMode(sender.isOn ? .performActions : .editActions)
        needsLayoutRefresh = true
        performDescription?.text = sender.isOn ? TTText("Screen taps perform actions") : TTText("Screen taps edit your buttons")
    }

    private func refreshRemotes() {
        let devices = appDelegate().bluetoothMonitor.foundDevices.devices
        for (id, title, detail) in remoteLabels {
            guard let device = devices.first(where: { $0.uuid == id }) else { detail.text = TTText("Disconnected"); continue }
            title.text = device.nickname ?? title.text
            detail.text = device.stateLabel().capitalized
            if device.state == .device_STATE_CONNECTED, let battery = device.batteryPct { detail.text! += TTText(" · {0}% battery", battery) }
        }
    }

    private func font(_ size: CGFloat, bold: Bool = false) -> UIFont {
        UIFont(name: bold ? "Effra-Bold" : "Effra", size: size) ?? .systemFont(ofSize: size, weight: bold ? .bold : .regular)
    }

    private func label(_ text: String, size: CGFloat, bold: Bool = false, color: UIColor? = nil) -> UILabel {
        let label = TTSettingsWrappingLabel()
        label.text = text
        label.font = font(size, bold: bold)
        label.textColor = color ?? ink
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    private func inset(_ child: UIView, by padding: CGFloat) -> UIView {
        let container = UIView()
        child.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            child.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding),
            child.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            child.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding)
        ])
        return container
    }

    private func section(_ name: String, rows: [UIView]) {
        let heading = label(name, size: 12, bold: true, color: muted)
        heading.attributedText = NSAttributedString(string: name, attributes: [.kern: 1])
        let headingInset = UIView()
        heading.translatesAutoresizingMaskIntoConstraints = false
        headingInset.addSubview(heading)
        NSLayoutConstraint.activate([heading.topAnchor.constraint(equalTo: headingInset.topAnchor), heading.bottomAnchor.constraint(equalTo: headingInset.bottomAnchor), heading.leadingAnchor.constraint(equalTo: headingInset.leadingAnchor, constant: 16), heading.trailingAnchor.constraint(equalTo: headingInset.trailingAnchor, constant: -16)])
        let card = UIStackView()
        card.axis = .vertical
        // A background view works on older UIKit versions where stack backgrounds are ignored.
        let background = UIView()
        background.backgroundColor = .white
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        card.insertSubview(background, at: 0)
        card.layer.cornerRadius = 14
        card.clipsToBounds = true
        for (index, row) in rows.enumerated() {
            if index > 0 {
                let divider = UIView()
                let line = UIView()
                line.backgroundColor = UIColor(hex: 0xE0E5E8)
                line.translatesAutoresizingMaskIntoConstraints = false
                divider.addSubview(line)
                NSLayoutConstraint.activate([divider.heightAnchor.constraint(equalToConstant: 0.5), line.leadingAnchor.constraint(equalTo: divider.leadingAnchor, constant: 56), line.trailingAnchor.constraint(equalTo: divider.trailingAnchor), line.topAnchor.constraint(equalTo: divider.topAnchor), line.bottomAnchor.constraint(equalTo: divider.bottomAnchor)])
                card.addArrangedSubview(divider)
            }
            card.addArrangedSubview(row)
        }
        let section = UIStackView(arrangedSubviews: [headingInset, card])
        section.axis = .vertical
        section.spacing = 8
        content.addArrangedSubview(section)
    }

    private func link(_ title: String, subtitle: String? = nil, icon: String, action: @escaping () -> Void) -> UIView {
        link(title: label(title, size: 17), subtitle: subtitle.map { label($0, size: 13, color: muted) }, icon: icon, action: action)
    }

    private func link(title: UILabel, subtitle: UILabel?, icon: String, action: @escaping () -> Void) -> UIView {
        let button = TTSettingsButton()
        button.action = action
        button.accessibilityLabel = [title.text, subtitle?.text].compactMap { $0 }.joined(separator: ", ")
        let image = UIImageView(image: UIImage(named: icon))
        image.contentMode = .scaleAspectFit
        image.widthAnchor.constraint(equalToConstant: 28).isActive = true
        image.heightAnchor.constraint(equalToConstant: 28).isActive = true
        let labels = UIStackView(arrangedSubviews: [title] + (subtitle.map { [$0] } ?? []))
        labels.axis = .vertical
        labels.spacing = 3
        let chevron = label("›", size: 26, color: UIColor(hex: 0xA5AFB7))
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [image, labels, chevron])
        row.alignment = .center
        row.spacing = 12
        let container = inset(row, by: 16)
        container.isUserInteractionEnabled = false
        container.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(container)
        NSLayoutConstraint.activate([container.topAnchor.constraint(equalTo: button.topAnchor), container.bottomAnchor.constraint(equalTo: button.bottomAnchor), container.leadingAnchor.constraint(equalTo: button.leadingAnchor), container.trailingAnchor.constraint(equalTo: button.trailingAnchor), button.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)])
        return button
    }
}

private final class TTSettingsButton: UIButton {
    var action: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? UIColor(hex: 0xF0F2F5) : .clear }
    }
    @objc private func pressed() { action?() }
}

/// Hosts the existing native setup UI without changing any remote button assignment.
final class TTSettingsConnectionViewController: UIViewController {
    let modeName: String
    private var options: TTOptionsDetailViewController?

    init(modeName: String) { self.modeName = modeName; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        guard let modeType = NSClassFromString("Turn_Touch_iOS.\(modeName)") as? TTMode.Type,
              let optionsType = NSClassFromString("Turn_Touch_iOS.\(modeName)Options") as? TTOptionsDetailViewController.Type else { return }
        title = modeType.title()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        let options = optionsType.init(nibName: "\(modeName)Options", bundle: .main)
        options.mode = modeType.init()
        // Mode options are stored per selected page, even when opened from Settings.
        options.mode.modeDirection = appDelegate().modeMap.selectedModeDirection
        options.menuType = .menu_MODE
        self.options = options
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        addChild(options)
        options.view.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(options.view)
        options.didMove(toParent: self)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor), scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            options.view.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), options.view.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor), options.view.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), options.view.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor), options.view.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
    }

    @objc private func close() { appDelegate().mainViewController.closeModal() }
}

/// Recalculate multiline height after a horizontal stack assigns its actual width.
private final class TTSettingsWrappingLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width > 0 && preferredMaxLayoutWidth != bounds.width {
            preferredMaxLayoutWidth = bounds.width
            invalidateIntrinsicContentSize()
        }
    }
}
