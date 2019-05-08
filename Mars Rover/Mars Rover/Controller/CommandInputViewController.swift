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
        dismiss(animated: true)
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        inputTextView.resignFirstResponder()
        
        guard let command = inputTextView.text else {
            return
        }
        
        if let site = CommandHelper.resolveMultiLineCommand(command) {
            self.mainVC.site = site
         
            dismiss(animated: true) {
                self.mainVC.replay()
            }
        } else {
            //TODO: error
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextView.becomeFirstResponder()
        
        inputTextView.text = mainVC.site.commandString

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
