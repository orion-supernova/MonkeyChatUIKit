//
//  WebViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 26.01.2023.
//

import UIKit
import WebKit
import SnapKit

final class WebViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        return view
    }()

    // MARK: - Private Properties
    private var url: URL?

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(url: URL) {
        self.init(nibName: nil, bundle: nil)
        self.url = url
        self.loadWebView()
    }

    deinit {
        print("WebViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        loadWebView()
    }

    // MARK: - Setup & Layout
    private func setup() {
        view.addSubview(webView)
    }

    private func layout() {
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - Private Methods
    private func loadWebView() {
        guard let url else { return }
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}

extension WebViewController: WKNavigationDelegate { }
