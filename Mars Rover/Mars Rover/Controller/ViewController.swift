//
//  ViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var groundView: UIImageView!
    @IBOutlet weak var groundViewWidth: NSLayoutConstraint!
    @IBOutlet weak var groundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gridView: UIImageView!
    
    @IBOutlet weak var controlsView: UIView!
   
    @IBAction func addButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func moveButtonTapped(_ sender: Any) {
        selectedRover?.actions.append(.moveForward)
        updateStatus()
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        selectedRover?.actions.append(.spinLeft)
        updateStatus()
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        selectedRover?.actions.append(.spinRight)
        updateStatus()
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        for rover in site.rovers {
            rover.actions.removeAll()
        }
        updateStatus()
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        if selectedRover?.actions.count != 0 {
            selectedRover?.actions.removeLast()
        }
        updateStatus()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var site: Site!
    
    var selectedRover: Rover? {
        didSet {
            updateStatus()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groundView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Mars"))
        groundViewWidth.constant = 2000
        groundViewHeight.constant = 2000
        
        gridView.backgroundColor = UIColor(patternImage: UIImage(imageLiteralResourceName: "grid-42"))
        
        site = Site(name: "Mars", grid: Coordinate(x: Int(view.bounds.width / 10.0), y: Int(view.bounds.height / 10.0)), rovers: [])
        updateStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let yOffset = max(0, (groundViewHeight.constant - scrollView.bounds.height))
        
        scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddRoverViewController {
            vc.mainVC = self
        }
    }

    
    func updateStatus() {
        if let rover = selectedRover {
            statusLabel.text = """
            Name: \(rover.name)
            Position: \(rover.finalPosition.string)
            """
        } else {
            statusLabel.text = nil
        }
    }

}

extension ViewController: UIScrollViewDelegate {
    
}
