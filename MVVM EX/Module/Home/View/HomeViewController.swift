//
//  HomeViewController.swift
//  MVVM EX
//
//  Created by Systems on 24/02/2024.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    
    let viewModel: HomeViewModelProtocol = HomeViewModel()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindingFromViewModelWithStates()
        setupRegisterTableView()
        subscribeWithTableView()
        bindToViewModel()
        viewModel.viewDidLoad()
        didSelectTableView()
    }

    func bindToViewModel() {
        searchTF.rx.text.orEmpty.bind(to: viewModel.input.searchTextBehavior).disposed(by: bag)
    }

    func subscribeWithTableView() {
        viewModel.output.postsPublish.bind(to: tableView.rx.items(cellIdentifier: String(describing: PostsCell.self), cellType: PostsCell.self)) { index, post, cell in
            cell.titleLabel.text = post.title
            cell.descriptionLabel.text = post.description
        }.disposed(by: bag)
    }

    func setupRegisterTableView() {
        tableView.register(UINib(nibName: String(describing: PostsCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: PostsCell.self))
    }

    func didSelectTableView() {
        tableView.rx.modelSelected(Post.self).subscribe(onNext: { [weak self] post in
            guard let self = self else {return}
            print(post.title)
            viewModel.navigateToViewController(post: post)
        }).disposed(by: bag)
    }
}

extension HomeViewController {
    func bindingFromViewModelWithStates() {
        viewModel.input.bindingState.subscribe(onNext: { [weak self] bindingStates in
            guard let self = self else {return}
            switch bindingStates {
            case .showHud:
                print("showHud")
            case .dismissHud:
                print("dismissHud")
            case .succeedMessage(let message):
                print(message)
            case .failMessage(let error):
                print(error)
            case .navigateToViewController(let post):
                let viewController = UIViewController()
                viewController.view.backgroundColor = .red
                print(post)
                self.present(viewController, animated: true)
            }
        }).disposed(by: bag)
    }
}
