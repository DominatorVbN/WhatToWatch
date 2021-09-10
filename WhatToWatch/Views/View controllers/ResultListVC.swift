//
//  ResultListVC.swift
//  WhatToWatch
//
//  Created by Amit Samant on 04/09/21.
//

import UIKit

protocol PrefrenceModalShowable {
    func showPrefrenceModal()
}

class ResultListVC<T: ResultListProvider>: UIViewController, UITableViewDataSource {

    let viewModel: T
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        configurePrefrenceModal()
        layoutViews()
        configureTable()
        reloadData()
    }
    
    @objc func showPrefrenceModal() {
        guard let showable = self as? PrefrenceModalShowable else {
            return
        }
        showable.showPrefrenceModal()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultCell = ResultCell(style: .default, reuseIdentifier: "ResultCell")
        let result = viewModel.results[indexPath.row]
        resultCell.titleLabel.text = result.title
        resultCell.subTitleLabel.text = result.mediaType
        resultCell.descriptionLabel.text = result.overview
        guard let url = result.imageURL else {
            return resultCell
        }
        viewModel.loadImage(forUrl: url) { image in
            resultCell.resultImageView.image = image
            resultCell.setNeedsLayout()
        }
        return resultCell
    }
    
    @objc func reloadData(_ sender: UIRefreshControl? = nil) {
        viewModel.fetch { [weak self] in
            self?.tableView.reloadData()
            sender?.endRefreshing()
        }
    }
    
}

private extension ResultListVC {
    
    func configurePrefrenceModal() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(showPrefrenceModal)
        )
    }
    
    func layoutViews() {
        tableView.allowsSelection = false
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
        tableView.register(
            UISwitchCell.self,
            forCellReuseIdentifier: UISwitchCell.reuseIdentifier
        )
        tableView.dataSource = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}

typealias ResultList<T: ResultListProvider> = ResultListVC<T> & PrefrenceModalShowable

