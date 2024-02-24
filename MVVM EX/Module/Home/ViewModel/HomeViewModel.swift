//
//  HomeViewModel.swift
//  MVVM EX
//
//  Created by Systems on 24/02/2024.
//

import Foundation
import RxSwift
import RxCocoa

protocol HomeViewModelProtocol: AnyObject {
    var input: HomeViewModel.Input { get }
    var output: HomeViewModel.Output { get }
    func viewDidLoad()
    func navigateToViewController(post: Post)
}

enum HomeBinding {
    case showHud
    case dismissHud

    case succeedMessage(String)
    case failMessage(String)

    case navigateToViewController(with: Post)
}

class HomeViewModel: HomeViewModelProtocol, ViewModel {
    class Input {
        var searchTextBehavior: BehaviorRelay<String> = .init(value: "")
        var bindingState: PublishSubject<HomeBinding> = .init()
    }

    class Output {
        var postsPublish: PublishSubject<[Post]> = .init()
    }

    var input: Input = .init()
    var output: Output = .init()

    private let bag = DisposeBag()
    private var collectedAllPostsPublish: PublishSubject<[Post]> = .init()

    func viewDidLoad() {
        handleSearchWithPostsOutput()
        callPostFromApi()
    }

    private func callPostFromApi() {
        input.bindingState.onNext(.showHud)
        let postFromApi: [Post] = [
            .init(title: "title 1", description: "description 1"),
            .init(title: "title 2", description: "description 2"),
            .init(title: "title 3", description: "description 3"),
            .init(title: "title 4", description: "description 4"),
            .init(title: "title 5", description: "description 5")
        ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            guard let self = self else {return}
            self.collectedAllPostsPublish.onNext(postFromApi)
            self.input.bindingState.onNext(.succeedMessage("Succeed Data from api"))
            self.input.bindingState.onNext(.dismissHud)
        }
    }

    private func handleSearchWithPostsOutput() {
        Observable.combineLatest(collectedAllPostsPublish, input.searchTextBehavior)
            .map { [weak self] (posts, search) in
                //guard let self = self else { return }
                if search.isEmpty { return posts }
                return posts.filter {$0.title.lowercased().contains(search.lowercased())}
            }.bind(to: output.postsPublish).disposed(by: bag)
    }

    func navigateToViewController(post: Post) {
        self.input.bindingState.onNext(.navigateToViewController(with: post))
    }
}
