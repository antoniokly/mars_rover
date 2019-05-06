//
//  ViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var gridView: UIView!
   
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Mars"))
        site = Site(name: "Mars", grid: Coordinate(x: Int(view.bounds.width / 10.0), y: Int(view.bounds.height / 10.0)), rovers: [])
        updateStatus()
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

