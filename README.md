reference : https://www.youtube.com/watch?v=M2psX-JwHdE&t=527s

# News App, Networking with Combine, Error Handling, UnitTest

<img width="40%" src="https://github.com/beakyangsu/iOS_News_Combine_Networking_UnitTest/assets/12162598/fa8dffae-1b3c-48b5-927e-63edf08440fb">
<img width="40%" alt="error" src="https://github.com/beakyangsu/iOS_News_Combine_Networking_UnitTest/assets/12162598/f6dfcaf0-0b7a-47ec-af28-c3bc4b488728">

❗**Combine, Error Handling, UnitTest**❗를 활용하여 News를 보여주는 프로젝트입니다. Combine을 이용해 Network코드를 구현하고, Generic type으로 리팩토링하여 코드 확장성을 키웠습니다. Error Handling을 통해 Networking에 error가 있을 경우 fetch retry를 하거나 error View를 화면에 보여주는 등의 적절한 대응 코드를 추가했습니다. UnitTest를 활용해 구현된 Combine Network의 success case와 fail case, Error Handling이 문제 없이 구현되었는지 확인했습니다. 


# Skills
<img alt="Static Badge" src="https://img.shields.io/badge/SwiftUI-blue"> <img alt="Static Badge" src="https://img.shields.io/badge/Swift-green"> <img alt="Static Badge" src="https://img.shields.io/badge/MVVM-red"> <img alt="Static Badge" src="https://img.shields.io/badge/@EnvironmentObject-yellow"> <img alt="Static Badge" src="https://img.shields.io/badge/Combine-blue"> <img alt="Static Badge" src="https://img.shields.io/badge/networking-blue"> <img alt="Static Badge" src="https://img.shields.io/badge/Error_Handling-blue"> <img alt="Static Badge" src="https://img.shields.io/badge/UnitTest-blue">

# What is My Role 
+ ViewModel과 data Model, View로 구성된 MVVM계층 구조를 설계하고 구현
+ <ins>Combine을 이용해 Network코드를 구현하고, 코드를 재사용할 수 있도록 Generic type으로 리팩토링</ins>

```
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
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .iso8601
                    return Just(data)
                        .decode(type: T.self, decoder: jsonDecoder)
                        .mapError {_ in APIError.decodingError } // decodingError 일경우 APIError.decodingError을 다운스트림
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: APIError.errorCode(response.statusCode)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher() // AnyPublisher로 한번더 랩핑
    }
}

```

+ <ins>NSCache</ins>를 이용해 download한 image를 저장하고, 한번 download된 image를 재 download하지않도록 성능 개선
+ Custom Error 타입을 정의하고 이를 이용해 Error Handling을 구현. Networking에 error가 있을 경우 fetch retry를 하거나 error View를 화면에 보여주는 등의 적절한 대응 코드를 추가
+ UnitTest를 활용해 구현된 Combine Network의 success case와 fail case, Error Handling이 문제 없이 구현되었는지 확인
+ <ins>UnitTest시나 UI구현시 불필요한 API호출을 최소화 하기위해 dummy data와 error를 return하는 MockUpService 구현</ins>


# What I learn? 
+ ### Why Combine for Networking?
  + Networking을 구현하는 많은 방법중 Combine을 사용해봤습니다.
  + 사실 Networking에 있어서 중요한점은 비동기(aync)로 동작해야한다는 점인데 사실 Combine은 비동기 프로그래밍이 아닌 State변화를 관찰 및 Update하기 위한 Framework지만 아이러니하게 변화가있을시 Update라는 특징이 비동기프로그래밍과도 비슷한 부분이 있어 Combine을 사용하는 경우도 많다고 하여 사용해봤습니다.
  + 현재는 aync/await이 사실 Networking에 있어 가장 효율적인 방식으로 평가받고있지만 <ins>aync/await은 iOS 15.0부터 등장했기때문에 15.0 이하 Target App 개발을 위해 complition handler나 Combine같은 반응형 프로그래밍 방식을이용한 Networking구현 방법을 숙지</ins>하는것도 중요하다고 생각합니다.

+ ### aync/await vs Complition handler vs Combine
  + 사실 aync/await과 Combine방식 complition handler방식을 모두 써봤는데 가장 코드가 간결하고, 구현이 쉬웠던것은 aync/await이었습니다.
  + <ins>aync/await과 달리 Combine방식과 complition handler방식에선 항상 메모리 릭을 발생시킬 수 있는 retain cycle을 조심해야 합니다.</ins>
  + Combine방식과 complition handler방식 중에선 Combine이 편했습니다.
  + <ins>complition handler방식에선 data전달을 위해선 또다른 handler를 사용하는등 handler를 중첩이 발생할 수 있고, 이는 곧 코드 가독성을 현저하게 떨어트리는데 Combine의 경우 성공, 실패 케이스에 따라 Publisher에 결과를 담아서 return처리하면 되기 때문에 비교적 가독성이좋고, 코드가 간결합니다.<\ins>

+ ### Error Handling
  + Networking에서 또 중요한 부분은 Error Handling이라고 생각합니다.
  +<ins> Networking은 많은 에러케이스가 존재하기때문에 이를 적절히 처리</ins>하지않으면 사용자에게 불편한 경험을 제공할 수 있기 때문입니다.
  + Error별로 적절히 구분하기 위해 Custom Error를 정의하였습니다.

+ ### UnitTest
  + UnitTest를 통해 실패, 성공 케이스를 정의하고 정상동작을 확인하는것은 중요하다고 생각합니다.
  + UnitTest가 빛을 발하는 상황은 <ins>리팩토링이나 이후 비지니스 로직이 새로 추가</ins>되어 코드 수정이 발생하는경우입니다.
  + 이럴경우 코드를 수정한뒤 UnitTest 실행을 통해 <ins>기존에 정상동작이던 기능들이 문제없이 동작하는지 빠르게 확인</ins>할 수 있습니다.
  + **안정적이고, 유지보수**하기 쉽게 만들어줍니다.
 
+ ### MockUpService
  + Networking이 포함된 앱을 구현할때 중요한 점은 <ins>불필요한 API 호출을 최소화 </ins>하는것입니다.
  + UnitTest를 하거나 UI를 구현하는데 실제 API호출이 이뤄질 필요는 없기때문에 별도의 MockUpService와 Dummy Data를 활용해 구현하는 것이 중요합니다.
  + <img width="569" alt="test" src="https://github.com/beakyangsu/iOS_News_Combine_Networking_UnitTest/assets/12162598/17b98e29-07a1-4cb4-a8ce-10e41836c0ab">

    
