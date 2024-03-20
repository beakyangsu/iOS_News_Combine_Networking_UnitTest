//
//  NewsViewModel.swift
//  Test2
//
//  Created by yangsu.baek on 2024/02/29.
//

import Foundation
import Combine
import SwiftUI

protocol NewsViewModel {
    func getArticles()
}

class NewsViewModelImpl : ObservableObject, NewsViewModel {

    private let service: NewsService
    private(set) var articles = [Article]()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set)var state: ResultState = .loading

    init(service: NewsService) {
        self.service = service
    }

    func getArticles() {
        //구독, 퍼블리셔에게 값을 요청해서 받아옴
        //getNews API사용
        let cancellable = service
            .request(from: .getNews, valueType: ArticleResponse.self)
            .sink { res in
                switch res {
                case .finished:
                    self.state = .success
                case .failure(let error) :
                    self.state = .failed(error: error)
                }

            } receiveValue: { response in
                self.articles = response.articles
            }
        self.cancellables.insert(cancellable)
    }
}

