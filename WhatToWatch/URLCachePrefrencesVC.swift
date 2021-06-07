//
//  URLCachePrefrencesVC.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import UIKit

struct URLCachePrefrences: Equatable {
    var selectedPolicyIndex = 0
    var selectedPolicy: URLRequest.CachePolicy {
        URLRequest.CachePolicy.allCases[selectedPolicyIndex]
    }
    var shouldUsediskBasedCache = false
    var cacheType: Provider<TMDBAPI>.CacheType {
        return .URLCache(useDiskBasedCache: shouldUsediskBasedCache, cachePolicy: URLRequest.CachePolicy.allCases[selectedPolicyIndex])
    }
}

class URLCachePrefrencesVC: UIViewController {
    
    
    enum Section: String, CaseIterable {
        case persistenceType = "Persistence Type"
        case cachePolicyPicker = "Cache policy"
    }
    
    var sections: [Section] = Section.allCases
    
    var preferences: URLCachePrefrences
    private var didCommitHook: (URLCachePrefrences) -> Void = { _ in }
    
    init(preferences: URLCachePrefrences) {
        self.preferences = preferences
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView: UITableView = {
        let tableView: UITableView
        if #available(iOS 13.0, *) {
            tableView = UITableView(frame: .infinite, style: .insetGrouped)
        } else {
            tableView = UITableView()
        }
        return tableView
    }()
    
    override func loadView() {
        super.loadView()
        title = "URLCache Preferences"
        navigationItem.largeTitleDisplayMode = .never
        layoutViews()
        configureTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.presentationController?.delegate = self
    }
    
    func layoutViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UISwitchCell.self, forCellReuseIdentifier: UISwitchCell.reuseIdentifier)
    }
    
    func commitAndDismiss() {
        self.dismiss(animated: true) { [preferences, didCommitHook] in
            didCommitHook(preferences)
        }
    }
    
    func didCommit(_ action: @escaping (URLCachePrefrences) -> Void) {
        self.didCommitHook = action
    }

}

extension URLCachePrefrencesVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .cachePolicyPicker:
            return URLRequest.CachePolicy.allCases.count
        case .persistenceType:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .persistenceType:
            let persistenceTypePickerCell = tableView.dequeueReusableCell(withIdentifier: UISwitchCell.reuseIdentifier, for: indexPath) as! UISwitchCell
            persistenceTypePickerCell.textLabel?.text = "Use disk based cache"
            persistenceTypePickerCell.switchControl.isOn = preferences.shouldUsediskBasedCache
            return persistenceTypePickerCell
        case .cachePolicyPicker:
            let policyItemCell = UITableViewCell(style: .default, reuseIdentifier: "PolicyItemCell")
            policyItemCell.textLabel?.text = URLRequest.CachePolicy.allCases[indexPath.row].title
            policyItemCell.textLabel?.adjustsFontSizeToFitWidth = true
            policyItemCell.accessoryType = .detailButton
            policyItemCell.imageView?.image =  UIImage(named: "checkmark")
            policyItemCell.imageView?.tintColor = preferences.selectedPolicyIndex == indexPath.row ? view.window?.tintColor ?? .systemBlue : .clear
            policyItemCell.selectionStyle = .none
            policyItemCell.separatorInset = .init(top: 0, left: -50, bottom: 0, right: 0)
            policyItemCell.clipsToBounds = true
            return policyItemCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        if section != .persistenceType {
            return section.rawValue
        } else {
            return nil
        }
    }
}


extension URLCachePrefrencesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard sections[indexPath.section] == .cachePolicyPicker else {
            return nil
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard sections[indexPath.section] == .cachePolicyPicker else {
            return
        }
        let lastSelectedIndexPath = IndexPath(row: preferences.selectedPolicyIndex, section: indexPath.section)
        preferences.selectedPolicyIndex = indexPath.row
        tableView.reloadRows(at: [lastSelectedIndexPath,indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard sections[indexPath.section] == .cachePolicyPicker else {
            return
        }
        let policy = URLRequest.CachePolicy.allCases[indexPath.row]
        let textVc = TextDetailVC(text: policy.info)
        textVc.title = policy.title
        let navVC = UINavigationController(rootViewController: textVc)
        self.present(navVC, animated: true)
    }
}


class TextDetailVC: UIViewController {
    let text: String
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.text = text
        label.numberOfLines = 0
        return label
    }()
    
    let scrollView = UIScrollView()
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: scrollView.readableContentGuide.topAnchor),
            textLabel.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension URLCachePrefrencesVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.commitAndDismiss()
        }))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
