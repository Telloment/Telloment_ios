//
//  PNUCheckerResponse.swift
//  Telloment
//
//  Created by 박진영 on 4/9/24.
//

import Foundation


struct PNUCheckerResponse: Codable {
    let str: String
    let errInfo: [ErrorInfo]
    let idx: Int
}

struct ErrorInfo: Codable {
    let help: String
    let errorIdx: Int
    let correctMethod: Int
    let errMsg: String
    let start: Int
    let end: Int
    let orgStr: String
    let candWord: String
}
