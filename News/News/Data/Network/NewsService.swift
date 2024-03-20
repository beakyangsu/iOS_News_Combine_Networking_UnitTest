//
//  NewsService.swift
//  Test2
//
//  Created by yangsu.baek on 2024/02/29.
//

import Foundation
import Combine

protocol NewsService {
    //변화하는값을 발신해주는 퍼블리셔, 변화를 트래킹해야하는 값
    func request<T: Decodable>(from endpoint: NewsAPI, valueType: T.Type) -> AnyPublisher<T, APIError>
}


struct NewsServiceImpl: NewsService {
    func request<T: Decodable>(from endpoint: NewsAPI, valueType: T.Type) -> AnyPublisher<T, APIError> {
        return URLSession
            .shared
            .dataTaskPublisher(for: endpoint.urlRequest) // request에 대한 처리
            .receive(on: DispatchQueue.main)
            .mapError{ _ in APIError.unknown } // urlRequest error 일경우 APIError.unknown을 다운스트림
            .flatMap{ data, response ->  AnyPublisher<T, APIError>  in
                //response nil 처리, Fail퍼블리셔를 anypublisher로 랩핑해서 리턴
                guard let response = response as? HTTPURLResponse else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }

                if(200...299).contains(response.statusCode) {
                    //성공

                    //json에 string 타입 date 값을  .iso8601 포맷의 Date으로 바꾸기 위한 디코더
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .iso8601
             
                    //article을 발행
                    return Just(data)
                        .decode(type: T.self, decoder: jsonDecoder)
                        .mapError {_ in APIError.decodingError } // decodingError 일경우 APIError.decodingError을 다운스트림
                        .eraseToAnyPublisher()
                } else {
                    //fail
                    return Fail(error: APIError.errorCode(response.statusCode)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher() // AnyPublisher로 한번더 랩핑
    }
}
