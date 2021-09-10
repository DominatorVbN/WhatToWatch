//
//  URLCachePrefrencesVC.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import UIKit

class URLCachePrefrencesVC: UITableViewController {
    
    private enum Section: String, CaseIterable {
        case persistenceType = "Persistence Type"
        case cachePolicyPicker = "Cache policy"
    }
    
    private var sections: [Section] = Section.allCases
    private var preferences: URLCachePrefrences
    private var didCommitHook: (URLCachePrefrences) -> Void = { _ in }
    
    override func loadView() {
        super.loadView()
        title = "URLCache Preferences"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    init(preferences: URLCachePrefrences, style: UITableView.Style) {
        self.preferences = preferences
        super.init(style: style)
        self.title = "NSCache Prefrences"
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        tableView.allowsSelection = false
        tableView.register(
            UISwitchCell.self,
            forCellReuseIdentifier: UISwitchCell.reuseIdentifier
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        navigationController?.presentationController?.delegate = self
    }
    
    func didCommit(_ action: @escaping (URLCachePrefrences) -> Void) {
        self.didCommitHook = action
    }
    
    private func commitAndDismiss() {
        self.dismiss(animated: true) { [preferences, didCommitHook] in
            didCommitHook(preferences)
        }
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .cachePolicyPicker:
            return URLRequest.CachePolicy.allCases.count
        case .persistenceType:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .persistenceType:
            let persistenceTypePickerCell = tableView.dequeueReusableCell(
                withIdentifier: UISwitchCell.reuseIdentifier,
                for: indexPath
            ) as! UISwitchCell
            persistenceTypePickerCell.textLabel?.text = "Use disk based cache"
            persistenceTypePickerCell.switchControl.isOn = preferences.shouldUsediskBasedCache
            persistenceTypePickerCell.didChangeValue { [weak self] isOn in
                self?.preferences.shouldUsediskBasedCache = isOn
            }
            return persistenceTypePickerCell
        case .cachePolicyPicker:
            let policyItemCell = UITableViewCell(
                style: .default,
                reuseIdentifier: "PolicyItemCell"
            )
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        if section != .persistenceType {
            return section.rawValue
        } else {
            return nil
        }
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard sections[indexPath.section] == .cachePolicyPicker else {
            return nil
        }
        return indexPath
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard sections[indexPath.section] == .cachePolicyPicker else {
            return
        }
        let lastSelectedIndexPath = IndexPath(row: preferences.selectedPolicyIndex, section: indexPath.section)
        preferences.selectedPolicyIndex = indexPath.row
        tableView.reloadRows(at: [lastSelectedIndexPath,indexPath], with: .none)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
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

// MARK: - UIAdaptivePresentationControllerDelegate
extension URLCachePrefrencesVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: "Save",
                style: .default,
                handler: { _ in self.commitAndDismiss() }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Discard",
                style: .destructive,
                handler: { _ in self.dismiss(animated: true, completion: nil) }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in alert.dismiss(animated: true, completion: nil) }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
}
