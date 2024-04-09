//
//  GrammarFeature.swift
//  Telloment
//
//  Created by 박진영 on 4/8/24.
//

import Foundation

class GrammarFeature {
    
    let API = PNUGrammerChecker()
    
    func checkGrammar(textToCheck: String, onResponsed: @escaping ([PNUCheckerResponse]) -> Void) {
        API.postCheckGrammar(textToCheck: textToCheck, onResponsed: onResponsed)
    }
    
    func fixGrammar(textToCheck: String, onResponded: @escaping (String) -> Void) {
        var res = textToCheck
        var offset = 0
        checkGrammar(textToCheck: textToCheck) { responses in
            responses.flatMap { response in
                response.errInfo
            }.forEach { err in
                let candword = err.candWord.split(separator: "|")[0]
                let startIndex = res.index(res.startIndex, offsetBy: err.start + offset)
                let endIndex = res.index(res.startIndex, offsetBy: err.end + offset)
                let range = startIndex..<endIndex
                offset = offset + (candword.count - (err.end - err.start))
                res.replaceSubrange(range, with: candword)
            }
            onResponded(res)
        }
    }

    
}
