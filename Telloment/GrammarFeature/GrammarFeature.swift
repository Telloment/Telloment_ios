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
    
    func getTest(onResponsed:@escaping(Response) -> Void) {
        AF.request(apiUrl,
                   method: .get,
        parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type": "application/json","Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: Response.self) { (response) in
            guard let res = response.value else {return}
            onResponsed(res)
        }
    }
    
    func checkSpell(textToCheck: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(PNU_URL ,
                       method:.post,
            parameters: nil,
                       encoding: URLEncoding.default,
                       headers: ["Content-Type": "application/x-www-form-urlencoded",
                                 "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"])
            .validate(statusCode: 200..<300)
            .responseString { response in
                guard let res = response.value else { return }
                continuation.resume(with: parseResponse(response: response))
            }
        }
    }
    
    private func parseResponse(response: String) -> String {
        return ""
    }
}

struct Response:Decodable {
    var userId: Int
    var id: Int
    var title: String
    var completed : Bool
    
}
