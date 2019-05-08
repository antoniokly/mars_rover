//
//  ViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import UIKit

let gridSize: CGFloat = 84

class ViewController: UIViewController {
    
    var animationQueue: [() -> Void] = []
    
    var site: Site! {
        didSet {
            statusLabel.text = nil
            animationQueue = []
            
            for v in roverViews.values {
                v.removeFromSuperview()
            }
            
            let minGroundSize = CGSize(
                width: ceil(view.bounds.width / gridSize) * gridSize,
                height: ceil(view.bounds.height / gridSize) * gridSize
            )
            
            let gridViewSize = CGSize(
                width: CGFloat(site.grid.x + 1) * gridSize,
                height: CGFloat(site.grid.y + 1) * gridSize
            )
            
            gridViewWidth.constant = gridViewSize.width
            gridViewHeight.constant = gridViewSize.height

            groundViewWidth.constant = max(gridViewSize.width, minGroundSize.width)
            groundViewHeight.constant = max(gridViewSize.height, minGroundSize.height)
            
            selectedRover = site.rovers.first
        }
    }
    
    var selectedRover: Rover? {
        didSet {
            if oldValue == selectedRover {
                return
            }
            
            updateStatus(for: selectedRover)
            
            for rover in site.rovers {
                if let v = roverViews[rover] {
                    if rover == selectedRover {
                        v.startFlashing()
                    } else {
                        v.stopFlashing()
                    }
                }
            }
        }
    }
    
    var roverViews: [Rover: RoverView] = [:]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var groundView: UIImageView!
    @IBOutlet weak var groundViewWidth: NSLayoutConstraint!
    @IBOutlet weak var groundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gridView: UIImageView!
    
    @IBOutlet weak var gridViewWidth: NSLayoutConstraint!
    @IBOutlet weak var gridViewHeight: NSLayoutConstraint!
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
        
        replay()
    }
    
    func replay() {
        animationQueue = []
        
        for v in roverViews.values {
            v.removeFromSuperview()
        }
        
        for rover in site.rovers {
            let view = createViewForRover(rover)
            roverViews[rover] = view
            gridView.addSubview(view)
            
            var position = rover.initialPosition
            
            animationQueue.append(contentsOf: rover.actions.map { (action) -> () -> Void in
                
                switch action {
                case .moveForward:
                    return { [weak self] in
                        guard self != nil else {return}
                        
                        self!.selectedRover = rover
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
                        guard self != nil else {return}
                        
                        self!.selectedRover = rover
                        position = action.transform(position)
                        view.rotateAnimationBlock(angle: CGFloat.pi / 2)()
                        self!.updateStatus(for: rover, at: position)
                    }
                case .spinRight:
                    return { [weak self] in
                        guard self != nil else {return}
                        
                        self!.selectedRover = rover
                        position = action.transform(position)
                        view.rotateAnimationBlock(angle: -CGFloat.pi / 2)()
                        self!.updateStatus(for: rover, at: position)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        centreScrollView(for: selectedRover)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddRoverViewController {
            vc.mainVC = self
        } else if let vc = segue.destination as? CommandInputViewController {
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
    
    func centreScrollView(for rover: Rover?, animated: Bool = true) {
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        if let rover = rover, let roverView = roverViews[rover] {
            xOffset = min(groundViewWidth.constant - scrollView.bounds.width,
                          max(0, roverView.center.x - scrollView.bounds.width / 2))
            yOffset = min(groundViewHeight.constant - scrollView.bounds.height,
                          max(0, roverView.center.y - scrollView.bounds.height / 2))
        } else {
            yOffset = max(0, (groundViewHeight.constant - scrollView.bounds.height))
        }
        
        scrollView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: animated)
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
        let point = gridView.convertCoordinateToPoint(position.coordinate, unitSize: unitSize)
        
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
