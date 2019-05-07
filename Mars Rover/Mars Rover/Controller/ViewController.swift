//
//  ViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import UIKit

let gridSize = CGSize(width: 42, height: 42)

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
        guard let rover = selectedRover, let roverView = roverViews[rover] else {
            return
        }
        
        let vector = rover.finalPosition.heading.vector
        
        rover.actions.append(.moveForward)
        
        self.updateStatus()
        
        roverView.move(x: vector.x * gridSize.width, y: -vector.y * gridSize.height)
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        guard let rover = selectedRover, let roverView = roverViews[rover] else {
            return
        }
        
        rover.actions.append(.spinLeft)
        
        self.updateStatus()
        
        roverView.rotate(angle: -CGFloat.pi / 2)
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        guard let rover = selectedRover, let roverView = roverViews[rover] else {
            return
        }
        
        rover.actions.append(.spinRight)
        
        self.updateStatus()
        
        roverView.rotate(angle: CGFloat.pi / 2)
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
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var site: Site!
    
    var selectedRover: Rover? {
        didSet {
            updateStatus()
        }
    }
    
    var roverViews: [Rover: UIView] = [:]
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groundView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Mars"))
        gridView.backgroundColor = UIColor(patternImage: UIImage(imageLiteralResourceName: "grid-42"))
        
        site = Site(name: "Mars",
                    grid: Coordinate(
                        x: Int(ceil(view.bounds.width / gridSize.width)),
                        y: Int(ceil(view.bounds.height / gridSize.height))),
                    rovers: [])
        
        groundViewWidth.constant = CGFloat(site.grid.x) * gridSize.width
        groundViewHeight.constant = CGFloat(site.grid.y) * gridSize.height
        
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
            \(rover.name)
            Position: \(rover.finalPosition.string)
            """
        } else {
            statusLabel.text = nil
        }
    }
    
    func addRover(_ rover: Rover) {
        site.rovers.append(rover)
        selectedRover = rover
        
        let view = UIImageView(image: UIImage(imageLiteralResourceName: "rover"))
        
        let point = toPoint(rover.initialPosition.coordinate)
        
        view.frame = CGRect(origin: point, size: gridSize)
        
        gridView.addSubview(view)
        
        roverViews[rover] = view
    }
    
    func toPoint(_ coordinate: Coordinate) -> CGPoint {
        
        return CGPoint(
            x: CGFloat(coordinate.x) * gridSize.width,
            y: CGFloat(site.grid.y - coordinate.y - 1) * gridSize.height)
    }

}

extension ViewController: UIScrollViewDelegate {
    
}


public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

extension Heading {
    var vector: CGPoint {
        switch self {
        case .E:
            return CGPoint(x: 1, y: 0)
        case .N:
            return CGPoint(x: 0, y: 1)
        case .W:
            return CGPoint(x: -1, y: 0)
        case .S:
            return CGPoint(x: 0, y: -1)
        }
    }
}

extension UIView {
    func move(x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.beginFromCurrentState],
                       animations: {
                        self.center = self.center.applying(
                            CGAffineTransform(translationX: x, y: y))
                        
        })
    }
    
    func rotate(angle: CGFloat) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.beginFromCurrentState],
                       animations: {
                        self.transform = self.transform.concatenating(CGAffineTransform(rotationAngle: angle))
        })
    }
}
