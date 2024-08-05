//
//  ViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SnapKit
import SideMenu

class ChatRoomListViewController: UIViewController {

    private lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any private room yet."
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 20)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        return emptyLabel
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatRoomListTableViewCell.self, forCellReuseIdentifier: "ChatRoomListTableViewCell")
        tableView.rowHeight = 60
        return tableView
    }()

    private lazy var swipeLeftView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - Private Properties
    private var viewModel = ChatRoomListViewModel()
    private var sideMenu: SideMenuNavigationController?

    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder: NSCoder) {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setDelegates()
        layout()
        fetchAndObserveChatRooms()
        addObservers()
    }

    deinit {
    }

    override func viewWillAppear(_ animated: Bool) {
        configureNavigationBar() // It is called from willAppear because username might be updated.
        updateLastMessages()
        AppGlobal.shared.currentPage = .chatList
    }

    override func viewDidLayoutSubviews() {
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .systemBackground
    }

    // MARK: - Setup
    private func setup() {
        view.addSubview(emptyLabel)
        view.addSubview(tableView)
        view.addSubview(swipeLeftView)
        setupSideMenu()
    }

    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.delegate = self
    }

    private func layout() {
        emptyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(40)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.left.right.bottom.equalToSuperview()
        }

        swipeLeftView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(20)
        }
    }

    private func setupSideMenu() {
        sideMenu = SideMenuNavigationController(rootViewController: ProfileViewController())
        sideMenu?.leftSide = true
        sideMenu?.setNavigationBarHidden(true, animated: false)

        SideMenuManager.default.leftMenuNavigationController = sideMenu
        SideMenuManager.default.addPanGestureToPresent(toView: swipeLeftView)
    }

    // MARK: - Functions
    func configureNavigationBar() {
        // FIXME: - This function should not be called from willAppear. Only the username stuff might be called from there.
        let createChatRoomButton = UIBarButtonItem(barButtonSystemItem: .compose,
                                                   target: self,
                                                   action: #selector(createChatRoomAction))
        navigationItem.rightBarButtonItems = [createChatRoomButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink

        let userSessionLabel : UILabel = {
            let label = UILabel()
            updateServerUsernameIfNeeded()
            // If the user is using multiple devices, username should match for all. So we check the server first to see if there is a given username.
            getUsernameFromServer { usernameFromServer in
                guard !usernameFromServer.isEmpty else {
                    if let usernameTemp = AppGlobal.shared.username {
                        label.text = "Your username: \(usernameTemp.isEmpty ? "Anonymous" : usernameTemp)"
                    } else {
                        label.text = "Your username: Anonymous"
                    }
                    return
                }
                label.text = "Your username: \(usernameFromServer)"
                AppGlobal.shared.username = usernameFromServer
            }
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 10)
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
            return label
        }()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .done, target: self, action: #selector(usernameAction))
        navigationItem.leftBarButtonItem?.tintColor = .systemPink

        let titleViewLabel : UILabel = {
            let label = UILabel()
            label.text = "MonkeyChat"
            label.font = .systemFont(ofSize: 18, weight: .bold)
            return label
        }()
        navigationItem.titleView = titleViewLabel
    }

    // MARK: - Private Methods
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(openChatRoomFromNotification(_:)), name: .openedChatRoomFromNotification, object: nil)
    }

    private func toggleEmptyView() {
        if viewModel.chatRooms.count == 0 {
            emptyLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            tableView.isHidden = false
        }
    }

    private func fetchAndObserveChatRooms() {
        viewModel.fetchChatRooms()
    }

    private func updateLastMessages() {
        //
    }

    @objc private func usernameAction() {
        guard let sideMenu else { return }
        self.present(sideMenu, animated: true)
    }

    /// Since the server control for username is added later, we are syncing the server data with the local username if its given.
    private func updateServerUsernameIfNeeded() {
        guard let username = AppGlobal.shared.username else { return }
        if username != "Anonymous" || username.isEmpty != true {
            COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").updateData(["username": username])
        }
    }

    private func getUsernameFromServer(completion: @escaping (String) -> Void) {
        guard let userID = AppGlobal.shared.userID else { return }
        COLLECTION_USERS.document(userID).getDocument { snapshot, error in
            guard let snapshot else { return }
            let dict = snapshot.data()
            let username = dict?["username"] as? String
            completion(username ?? "")
        }
    }

    private func getProfilePictureFromDisk(completion: @escaping (UIImage) -> Void) {
        let viewModel = ProfileViewModel()
        viewModel.getProfilePictureFromDisk { success, image in
            guard success else { return }
            guard let image else { return }
            completion(image)
        }
    }

    // MARK: - Actions
    @objc func createChatRoomAction() {
        viewModel.createRoomOrEnterRoomAction()
    }

    @objc private func openChatRoomFromNotification(_ sender: Notification?) {
        guard let chatRoomID = sender?.object as? String else { return }
        guard let chatRoom = viewModel.chatRooms.first(where: { $0.id == chatRoomID }) else { return }
        let viewController = ChatRoomViewController(chatRoom: chatRoom)
        AppGlobal.shared.lastEnteredChatRoomID = chatRoomID
        self.navigationController?.pushViewController(viewController, animated: false)
    }
}

// MARK: UITableViewDataSource
extension ChatRoomListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomListTableViewCell", for: indexPath) as? ChatRoomListTableViewCell else { return UITableViewCell() }
        cell.configureCell(chatRoom: viewModel.chatRooms[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatRooms.count
    }
}

// MARK: UITableView Delegate
extension ChatRoomListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = ChatRoomViewController(chatRoom: viewModel.chatRooms[indexPath.row])
        AppGlobal.shared.lastEnteredChatRoomID = viewModel.chatRooms[indexPath.row].id ?? ""
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "") { [weak self] (action, view, completionHandler) in
            self?.nudgeAction(indexPath: indexPath)
            completionHandler(true)
        }
        action.image = getNudgeTitleWithImage()
        action.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [action])
    }

    private func nudgeAction(indexPath: IndexPath) {
        AlertHelper.alertMessage(viewController: self, title: "Send a Nudge", message: "Do you want to send a nudge to this room?", okButtonText: "Yeap") {[weak self] in
            guard let self = self else { return }
            self.viewModel.sendNudge(to: indexPath)
        }
    }

    private func getNudgeTitleWithImage() -> UIImage? {
        let text = NSMutableAttributedString()
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "bolt")
        attachment.image?.withTintColor(.systemPink)
        text.append(NSAttributedString(attachment: attachment))
        text.append(NSAttributedString(string: "Nudge"))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.textAlignment = .center
        label.numberOfLines = 2
        label.attributedText = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .black
        let renderer = UIGraphicsImageRenderer(bounds: label.bounds)
        let image = renderer.image { context in
            label.layer.render(in: context.cgContext)
        }
        guard let cgImage = image.cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
}
// MARK: ChatRoomListViewModel Delegate
extension ChatRoomListViewController: ChatRoomListViewModelDelegate {
    func presentAlertController(_ alertController: UIAlertController, animated: Bool, completion: (() -> Void)?) {
        self.present(alertController, animated: animated, completion: completion)
    }

    func didChangeDataSource() {
        DispatchQueue.main.async {
            self.toggleEmptyView()
            UIView.transition(with: self.tableView,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData() })
        }
    }
}

