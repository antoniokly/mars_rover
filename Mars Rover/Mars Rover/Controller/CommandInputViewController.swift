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
            let site = try CommandHelper.resolveMultiLineCommand(command)
            self.mainVC.site = site
            
            self.dismiss(animated: true) {
                self.mainVC.replay(shouldShowResults: true)
            }
        } catch let error as NSError {
            let alert = UIAlertController(title: "Command Error", message: error.message ?? "Command error, please retry.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.inputTextView.becomeFirstResponder()
            }))
            
            present(alert, animated: true)
        }
    }
    
    @IBAction func instructionsButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Instructions", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        let messageText = NSMutableAttributedString(
            string: instructions,
            attributes: [
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0)
            ]
        )
        
        alert.setValue(messageText, forKey: "attributedMessage")
        
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextView.becomeFirstResponder()
        
        inputTextView.text = mainVC.site.commandString
    }
}

let instructions =
"""
The possible letters are 'N', 'E', 'S', 'W' (representing the rover's orientation), 'L', 'R' and 'M'. 'L' and 'R' makes the rover spin 90 degrees left or right respectively, without moving from its current spot. 'M' means move forward one grid point, and maintain the same heading.

The first line of input is the upper-right coordinates of the plateau, the lower-left coordinates are assumed to be 0,0.
The rest of the input is information pertaining to the rovers that have been deployed. Each rover has two lines of input. The first line gives the rover's position, and the second line is a series of instructions telling the rover how to explore the plateau. The position is made up of two integers and a letter separated by spaces, corresponding to the x and y co-ordinates and the rover's orientation.
Each rover will be finished sequentially, which means that the second rover won't start to move until the first one has finished moving.

Example:
5 5
1 2 N
LMLMLMLMM
3 3 E
MMRMMRMRRM
"""
