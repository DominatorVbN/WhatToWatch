//
//  NSCachePrefrencesVC.swift
//  WhatToWatch
//
//  Created by Amit Samant on 11/09/21.
//

import UIKit

class NSCachePrefrencesVC: UITableViewController {
    
    private enum Section: String, CaseIterable {
        case persistenceType = "Persistence Type"
    }
    
    private var sections: [Section] = Section.allCases
    private var preferences: NSCachePreferences
    private var didCommitHook: (NSCachePreferences) -> Void = { _ in }
    
    init(preferences: NSCachePreferences, style: UITableView.Style) {
        self.preferences = preferences
        super.init(style: style)
        self.title = "NSCache Prefrences"
        navigationItem.largeTitleDisplayMode = .never
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didCommit(_ action: @escaping (NSCachePreferences) -> Void) {
        self.didCommitHook = action
    }
    
    func commitAndDismiss() {
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
        }
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension NSCachePrefrencesVC: UIAdaptivePresentationControllerDelegate {
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
