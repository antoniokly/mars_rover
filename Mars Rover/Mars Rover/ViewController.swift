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
        let name = "Rover \(site.rovers.count + 1)"
        
        let rover = Rover(name: name, position: Position(coordinate: Coordinate(x: 0,y: 0), heading: .E))
        
        site.rovers.append(rover)
        selectedRover = rover
    }
    
    @IBAction func moveButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
    }
    
    @IBAction func replayButtonTapped(_ sender: Any) {
        
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
        
        site = Site(name: "Mars", grid: Coordinate(x: Int(view.bounds.width / 10.0), y: Int(view.bounds.height / 10.0)), rovers: [])
        updateStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

