//
//  GrammarFeature.swift
//  Telloment
//
//  Created by 박진영 on 4/8/24.
//

import Foundation
import Alamofire

class GrammarFeature {
    let PNU_URL = "http://speller.cs.pusan.ac.kr/results"

    func checkGrammar(textToCheck: String, onResponsed: @escaping ([PNUCheckerResponse]) -> Void) {
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
    
    func fixGrammar(textToCheck: String, onResponded: @escaping (String) -> Void) {
        checkGrammar(textToCheck: <#T##String#>) { responses in
            
            
        }
    }

    private func parseResponse(response: String) -> [PNUCheckerResponse] {
        let regex = /\tdata = \[.*\]/
        let res = response.matches(of: regex)
            .compactMap { matcher -> [PNUCheckerResponse]? in
                var t = String(response[matcher.range])
                let start = t.index(t.startIndex, offsetBy: 8)
                let end = t.index(t.endIndex, offsetBy: 0)
                t = String(t[start ..< end])
                t.removingRegexMatches(pattern: "<[^ㄱ-ㅎㅏ-ㅣ가-힣>]+>")
                if let jsonData = t.data(using: .utf8) {
                    do {
                        let dataModels = try JSONDecoder().decode([PNUCheckerResponse].self, from: jsonData)
                        return dataModels
                    } catch {
                        print("Error decoding JSON: \(error)")
                        return nil
                    }
                }
                return nil
            }.flatMap {$0}
        return res
    }
}
