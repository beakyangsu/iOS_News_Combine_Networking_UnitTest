//
//  Test2Tests_News_Combine.swift
//  Test2Tests_News_Combine
//
//  Created by yangsu.baek on 2024/03/01.
//

import XCTest
import Combine
@testable import News


final class Test2Tests_News_Combine: XCTestCase {

    private var viewModel: NewsViewModelImpl!
    private var newsService : MockNewsAPIService! //mock 서비스를 생성

    override func setUp() {
        super.setUp()
        newsService = MockNewsAPIService()
        viewModel = NewsViewModelImpl(service: newsService)
    }

    override func tearDown() {
        super.tearDown()
    }

    //given
    //when
    //then
    func testFetchNews_onAppearWithAPISuccess_thenStateSuccess() {
        //given
        let article1 = Article.init(
            author: nil,
            url: "https://www.bbc.com/news/uk-68421992",
            source:  "BBC News",
            title: "Prince Harry loses High Court challenge over UK security levels - BBC.com",
            description: "The Duke of Sussex fails to overturn a ruling which saw his security status downgraded in the UK.",
            image: "https://ichef.bbci.co.uk/news/1024/branded_news/18206/production/_131922889_ace90c4a92ac8d3f6cb815fa951c317daeeef999.jpg",
            date: nil)
        let article2  = Article.init(
            author: "Maggie Penman",
            url: "https://www.washingtonpost.com/climate-solutions/2024/02/28/microplastics-drinking-water/",
            source:  "The Washington Post",
            title: "A simple way to remove microplastics from drinking water - The Washington Post",
            description: "New research shows boiling water is surprisingly effective at removing the ubiquitous tiny plastic particles.",
            image: "https://www.washingtonpost.com/wp-apps/imrs.php?src=https://arc-anglerfish-washpost-prod-washpost.s3.amazonaws.com/public/PRNOBELWFWSWEMQCFZV55HRAFQ_size-normalized.jpg&w=1440",
            date: nil)


        let mockArticles = [article1, article2]
        let newsRespnse = ArticleResponse.init(articles: mockArticles)
        newsService.fetchResult = CurrentValueSubject<ArticleResponse, APIError>(newsRespnse).eraseToAnyPublisher()

        viewModel.getArticles()
        //when
        //then
        XCTAssertEqual(viewModel.articles.count, 2)
    }

    func testFetchNews_onAppearWithAPI_unKnownFail_thenStateFail() {
        //given
        newsService.fetchResult = Fail<ArticleResponse, APIError>(error: APIError.unknown).eraseToAnyPublisher()
        viewModel.getArticles()
        //when
        //then
        switch viewModel.state {
        case.success :
            XCTFail()
        case .loading:
            XCTFail()
        case .failed(error: let error):
            XCTAssertEqual(error.localizedDescription, APIError.unknown.errorDescription)
        }
    }

    func testFetchNews_onAppearWithAPI_decodingError_thenStateFail() {
        //given
        newsService.fetchResult = Fail<ArticleResponse, APIError>(error: APIError.decodingError).eraseToAnyPublisher()
        viewModel.getArticles()
        //when
        //then
        switch viewModel.state {
        case.success:
            XCTFail()
        case .loading:
            XCTFail()
        case .failed(error: let error):
            XCTAssertEqual(error.localizedDescription, APIError.decodingError.errorDescription)
        }
    }

    func testFetchNews_onAppearWithAPI_errorCode_thenStateFail() {
        //given
        newsService.fetchResult = Fail<ArticleResponse, APIError>(error: APIError.errorCode(400)).eraseToAnyPublisher()
        viewModel.getArticles()
        //when
        //then
        switch viewModel.state {
        case.success :
            XCTFail()
        case .loading:
            XCTFail()
        case .failed(error: let error):
            XCTAssertEqual(error.localizedDescription, APIError.errorCode(400).errorDescription)
        }
    }
}

//mock 을 만드는이유
//실제 api콜을 수행하는것 불필요함
//결과가 제대로 수신/발신 하는지만 확인하면됨

class MockNewsAPIService: NewsService {

    var fetchResult: Any?
    func request<T:Decodable>(from endpoint: News.NewsAPI, valueType: T.Type) -> AnyPublisher<T, News.APIError> where T : Decodable {
        if let result = fetchResult as? AnyPublisher<T, News.APIError> {
            return result
        } else {
            fatalError("result must not be nil")
        }
    }
}

