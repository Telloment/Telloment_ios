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
}

struct Response:Decodable {
    var userId: Int
    var id: Int
    var title: String
    var completed : Bool
    
}
