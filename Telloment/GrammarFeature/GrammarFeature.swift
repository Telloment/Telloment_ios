//
//  GrammarFeature.swift
//  Telloment
//
//  Created by 박진영 on 4/8/24.
//

import Foundation
import Alamofire

class GrammarFeature {
    let apiUrl = "https://jsonplaceholder.typicode.com/todos/1"
    let PNU_URL = "http://speller.cs.pusan.ac.kr/results"

    func getTest(onResponsed: @escaping (TestResponse) -> Void) {
        AF.request(apiUrl,
                        method: .get,
                        parameters: nil,
                        encoding: URLEncoding.default,
                        headers: ["Content-Type": "application/json", "Accept": "application/json"])
                .validate(statusCode: 200..<300)
                .responseDecodable(of: TestResponse.self) { (response) in
                    guard let res = response.value else {
                        return
                    }
                    onResponsed(res)
                }
    }

    func checkGrammar(textToCheck: String, onResponsed: @escaping (String) -> Void) {
        AF.request(PNU_URL,
                        method: .post,
                   parameters: ["text1": textToCheck],
                        encoding: URLEncoding.default)
                .validate(statusCode: 200..<300)
                .responseString { response in
                    print(response.result)
                    guard let res = response.value else {
                        return
                    }
                    onResponsed(self.parseResponse(response: res))
                }
    }

    private func parseResponse(response: String) -> String {
        return ""
    }
}

struct TestResponse: Decodable {
    var userId: Int
    var id: Int
    var title: String
    var completed: Bool

}
