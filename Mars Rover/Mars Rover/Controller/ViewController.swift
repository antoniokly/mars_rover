//
//  ViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import UIKit

let gridSize: CGFloat = 84

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
        
        let angle = CGFloat(rover.finalPosition.heading.angle)
        
        rover.actions.append(.moveForward)
        
        let animation = roverView.moveAnimationBlock(distance: gridSize,
                                                     angle: angle)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [],
                       animations: animation,
                       completion: { _ in
                        self.updateStatus(for: rover)
                        
                        let visible = CGRect(origin: self.scrollView.frame.origin + self.scrollView.contentOffset, size: self.scrollView.frame.size)
                        
                        if !visible.intersects(roverView.frame) {
                            self.centreScrollView(for: rover)
                        }
        })
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        guard let rover = selectedRover, let roverView = roverViews[rover] else {
            return
        }
        
        rover.actions.append(.spinLeft)
        
        let animation = roverView.rotateAnimationBlock(angle: CGFloat.pi / 2)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [],
                       animations: animation,
                       completion: { _ in
                        self.updateStatus(for: rover)
        })
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        guard let rover = selectedRover, let roverView = roverViews[rover] else {
            return
        }
        
        rover.actions.append(.spinRight)
        
        let animation = roverView.rotateAnimationBlock(angle: -CGFloat.pi / 2)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [],
                       animations: animation,
                       completion: { _ in
                        self.updateStatus(for: rover)
        })
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        for rover in site.rovers {
            rover.actions.removeAll()
            
            roverViews[rover]?.removeFromSuperview()
            let view = createViewForRover(rover)
            roverViews[rover] = view
            gridView.addSubview(view)
        }
        
        selectedRover = site.rovers.first
    }
    
    @IBAction func undoButtonTapped(_ sender: Any) {
        guard let rover = selectedRover else {
            return
        }
        
        if rover.actions.count != 0 {
            rover.actions.removeLast()
        }
        
        updateStatus(for: rover)
    }
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        //TODO: disable buttons
        
        animationQueue = []
        
        for rover in site.rovers {
            roverViews[rover]?.removeFromSuperview()
            
            let view = createViewForRover(rover)
            roverViews[rover] = view
            gridView.addSubview(view)
            view.startFlashing()
            
            var position = rover.initialPosition
            
            animationQueue.append(contentsOf: rover.actions.map { (action) -> () -> Void in
                
                switch action {
                case .moveForward:
                    return { [weak self] in
                        guard self != nil else {return}
                        
                        let angle = CGFloat(position.heading.angle)
                        position = action.transform(position)
                        view.moveAnimationBlock(distance: gridSize, angle: angle)()
                        self!.updateStatus(for: rover, at: position)

                        let visible = CGRect(origin: self!.scrollView.frame.origin + self!.scrollView.contentOffset, size: self!.scrollView.frame.size)
                        
                        if !visible.intersects(view.frame) {
                            self!.centreScrollView(for: rover)
                        }
                    }
                case .spinLeft:
                    return { [weak self] in
                        position = action.transform(position)
                        view.rotateAnimationBlock(angle: CGFloat.pi / 2)()
                        self?.updateStatus(for: rover, at: position)
                    }
                case .spinRight:
                    return { [weak self] in
                        position = action.transform(position)
                        view.rotateAnimationBlock(angle: -CGFloat.pi / 2)()
                        self?.updateStatus(for: rover, at: position)
                    }
                }
            })
        }
        
        drainAnimationQueue()
    }
    
    
    func drainAnimationQueue() {
        guard !animationQueue.isEmpty else {
            //TODO: re-enable buttons
            return
        }
        
        let animation = animationQueue.removeFirst()
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveLinear],
                       animations: animation,
                       completion: { (finish) in self.drainAnimationQueue() })
    }
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var animationQueue: [() -> Void] = []
    
    var site: Site!
    
    var selectedRover: Rover? {
        didSet {
            updateStatus(for: selectedRover)
            
            for rover in site.rovers {
                if let v = roverViews[rover] {
                    rover == selectedRover ? v.startFlashing() : v.stopFlashing()
                }
            }
        }
    }
    
    var roverViews: [Rover: RoverView] = [:]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Mars"))
        groundView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Mars"))
        gridView.backgroundColor = UIColor(patternImage: UIImage(imageLiteralResourceName: "grid-84"))
        
        let siteSize = Int(ceil(max(view.bounds.width, view.bounds.height) / gridSize))
        
        site = Site(name: "Mars",
                    grid: Coordinate(x: siteSize, y: siteSize),
                    rovers: [])
        
        groundViewWidth.constant = CGFloat(site.grid.x) * gridSize
        groundViewHeight.constant = CGFloat(site.grid.y) * gridSize
        
        statusLabel.text = nil
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
    
    func updateStatus(for rover: Rover?, at position: Position? = nil) {
        guard let rover = rover else {
            statusLabel.text = nil
            return
        }
        
        statusLabel.text = """
        \(rover.name)
        Position: \(position?.string ?? rover.finalPosition.string)
        """
    }
    
    func centreScrollView(for rover: Rover) {
        guard let roverView = roverViews[rover] else {
            return
        }
        
        let xOffset = min(groundViewWidth.constant - scrollView.bounds.width,
                          max(0, roverView.center.x - scrollView.bounds.width / 2))
        
        let yOffset = min(groundViewHeight.constant - scrollView.bounds.height,
                          max(0, roverView.center.y - scrollView.bounds.height / 2))
        
        scrollView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: true)
    }
    
    func addRover(_ rover: Rover) {
        site.rovers.append(rover)
        
        let view = createViewForRover(rover)
        roverViews[rover] = view
        gridView.addSubview(view)
        
        selectedRover = rover
        centreScrollView(for: rover)
    }
    
    func createViewForRover(_ rover: Rover) -> RoverView {
        let unitSize = CGSize(width: gridSize, height: gridSize)
        let position = rover.initialPosition
        let point = convertToPoint(position.coordinate, in: site.grid, unitSize: unitSize)
        
        let view = RoverView(rover: rover)
        view.frame = CGRect(origin: point, size: unitSize)
        view.rotateAnimationBlock(angle: CGFloat(position.heading.angle))()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true

        return view
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        selectedRover = (sender.view as? RoverView)?.rover
    }
}




