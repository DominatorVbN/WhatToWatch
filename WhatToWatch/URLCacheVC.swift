//
//  ViewController.swift
//  WhatToWatch
//
//  Created by Amit Samant on 05/06/21.
//

import UIKit

class URLCacheViewModel {
    var prefrences: URLCachePrefrences = .init()
    var results: [TMDBResult] = []
    
    func fetch(_ completion: @escaping () -> Void = {}) {
        TMDBAPI.provider.fetch(api: .trending, cacheType: prefrences.cacheType) { (result: Result<PaginatedTrendingResponse, Error>) in
            switch result {
            case .success(let response):
                self.results = response.results
            case .failure:
                self.results = []
            }
            completion()
        }
    }
    
}

class URLCacheVC: UIViewController {
    
    let viewModel = URLCacheViewModel()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func loadView() {
        super.loadView()
        title = "URLCache"
        layoutViews()
        configureTable()
        reloadData()
    }
    
    func reloadData() {
        viewModel.fetch { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            
        }
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
    
    func configurePrefrenceModal() {
        
    }
    
    func showPrefrenceModal() {
        let prefrencesVC = URLCachePrefrencesVC(preferences: viewModel.prefrences)
        let navigationVC = UINavigationController(rootViewController: prefrencesVC)
        prefrencesVC.didCommit { [weak self] prefrences in
            self?.viewModel.prefrences = prefrences
            self?.reloadData()
        }
        self.present(navigationVC, animated: true)
    }

}

extension URLCacheVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultCell = ResultCell(style: .default, reuseIdentifier: "ResultCell")
        let result = viewModel.results[indexPath.row]
        if let url = result.imageURL {
        TMDBAPI.provider.loadImage(url: url, cacheType: viewModel.prefrences.cacheType) {  image in
            DispatchQueue.main.async {
                resultCell.resultImageView.image = image
                resultCell.setNeedsLayout()
            }
        }
        }
        resultCell.titleLabel.text = result.title
        resultCell.subTitleLabel.text = result.mediaType
        resultCell.descriptionLabel.text = result.overview
        
        return resultCell
    }
    
}

extension URLCacheVC: UITableViewDelegate {
}
