//
//  CommandInputViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 9/05/19.
//

import UIKit

class CommandInputViewController: UIViewController {
    weak var mainVC: ViewController!
    
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        inputTextView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        inputTextView.resignFirstResponder()
        
        guard let command = inputTextView.text else {
            return
        }
        
        do {
            if let site = try CommandHelper.resolveMultiLineCommand(command) {
                self.mainVC.site = site
                
                dismiss(animated: true) {
                    self.mainVC.replay()
                }
            }
        } catch let error as NSError {
            let alert = UIAlertController(title: nil, message: error.message ?? "Command error, please retry.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.inputTextView.becomeFirstResponder()
            }))
            
            present(alert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextView.becomeFirstResponder()
        
        inputTextView.text = mainVC.site.commandString
    }
}
