//
//  TempViewController.swift
//  Telloment
//
//  Created by 최병욱 on 4/5/24.
//

import UIKit

class TempViewController:UIViewController{
    
    let grammarFeature = GrammarFeature()
    @IBOutlet weak var GrammarTextField: UITextField!
    
    
    @IBAction func GrammarButtonTapped(_ sender: Any) {
        
        grammarFeature.fixGrammar(textToCheck: GrammarTextField.text ?? "") { result in
            self.GrammarTextField.text = result
        }
            
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
          self.view.endEditing(true)
    }
    
    
}
