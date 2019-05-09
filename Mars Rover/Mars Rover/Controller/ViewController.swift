//
//  ViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 5/05/19.
//

import UIKit

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
            for rover in site.rovers {
                roverViews[rover]?.stopFlashing()
            }
            
            if let rover = selectedRover {
                roverViews[rover]?.startFlashing()
            }
            
            updateStatus(for: selectedRover)
        }
    }
    
    var roverViews: [Rover: RoverView] = [:]
    
    var restored: Bool = false
    
    @IBOutlet weak var addButton: RoundButton!
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
        
        do {
            try rover.addAction(.moveForward, in: site)
        } catch let error as NSError {
            let alert = UIAlertController(title: nil, message: error.message ?? "Unknown error.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alert, animated: true)
            
            return
        }
        
        let animation = roverView.moveAnimationBlock(distance: gridSize,
                                                     angle: angle)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseInOut],
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
        
        try? rover.addAction(.spinLeft, in: site)
        
        let animation = roverView.rotateAnimationBlock(angle: CGFloat.pi / 2)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: animation,
                       completion: { _ in
                        self.updateStatus(for: rover)
        })
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        guard let rover = selectedRover, let roverView = roverViews[rover] else {
            return
        }
        
        try? rover.addAction(.spinRight, in: site)
        
        let animation = roverView.rotateAnimationBlock(angle: -CGFloat.pi / 2)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: animation,
                       completion: { _ in
                        self.updateStatus(for: rover)
        })
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        if site.rovers.flatMap({$0.actions}).isEmpty {
            return
        }
        
        let alert = UIAlertController(title: nil, message: "Are you sure to reset all rovers to their initial positions?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action) in
            self.reset()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
       
    }
    
    @IBAction func replayButtonTapped(_ sender: Any) {
        replay()
    }
    
    func reset() {
        for rover in site.rovers {
            rover.removeAllActions()
            roverViews[rover]?.removeFromSuperview()
            
            let roverView = createViewForRover(rover)
            roverViews[rover] = roverView
            gridView.addSubview(roverView)
        }
        
        selectedRover = site.rovers.first
    }
    
    func disableControls() {
        addButton.alpha = 0.2
        addButton.isEnabled = false
        
        controlsView.alpha = 0.2
        controlsView.isUserInteractionEnabled = false
    }
    
    func enableControls() {
        addButton.alpha = 1
        addButton.isEnabled = true
        
        controlsView.alpha = 1
        controlsView.isUserInteractionEnabled = true
    }
    
    func replay() {
        disableControls()
        
        animationQueue = []
        
        for v in roverViews.values {
            v.removeFromSuperview()
        }
        
        for rover in site.rovers {
            let roverView = createViewForRover(rover)
            roverViews[rover] = roverView
            gridView.addSubview(roverView)
            
            var position = rover.initialPosition
            
            animationQueue.append(contentsOf: rover.actions.map { (action) -> () -> Void in
                
                switch action {
                case .moveForward:
                    return { [weak self] in
                        guard self != nil else {return}
                        
                        self!.selectedRover = rover
                        let angle = CGFloat(position.heading.angle)
                        position = action.transform(position)
                        roverView.moveAnimationBlock(distance: gridSize, angle: angle)()
                        self!.updateStatus(for: rover, at: position)
                        
                        let visible = CGRect(origin: self!.scrollView.frame.origin + self!.scrollView.contentOffset, size: self!.scrollView.frame.size)
                        
                        if !visible.intersects(roverView.frame) {
                            self!.centreScrollView(for: rover)
                        }
                    }
                case .spinLeft:
                    return { [weak self] in
                        guard self != nil else {return}
                        
                        self!.selectedRover = rover
                        position = action.transform(position)
                        roverView.rotateAnimationBlock(angle: CGFloat.pi / 2)()
                        self!.updateStatus(for: rover, at: position)
                    }
                case .spinRight:
                    return { [weak self] in
                        guard self != nil else {return}
                        
                        self!.selectedRover = rover
                        position = action.transform(position)
                        roverView.rotateAnimationBlock(angle: -CGFloat.pi / 2)()
                        self!.updateStatus(for: rover, at: position)
                    }
                }
            })
        }
        
        drainAnimationQueue()
    }
    
    func drainAnimationQueue() {
        guard !animationQueue.isEmpty else {
            enableControls()
            selectedRover = site.rovers.last
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
        
        if let command = UserDefaults.standard.string(forKey: "command") {
            do {
                if let site = try CommandHelper.resolveMultiLineCommand(command) {
                    self.site = site
                    restored = true
                }
            } catch {
                UserDefaults.standard.removeObject(forKey: "command")
            }
        }
        
        if site == nil {
            let siteSize = Int(ceil(max(view.bounds.width, view.bounds.height) / gridSize))
            
            site = Site(name: "Mars",
                        grid: Coordinate(x: siteSize, y: siteSize),
                        rovers: [])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if restored {
            for rover in site.rovers {
                let roverView = createViewForRover(rover, atFinalposition: true)
                roverViews[rover] = roverView
                gridView.addSubview(roverView)
            }
            selectedRover = site.rovers.last
        }
        
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
    
    func setupView(for rover: Rover, atFinalposition: Bool = false ) {
        let roverView = createViewForRover(rover)
        roverViews[rover] = roverView
        gridView.addSubview(roverView)
        
        selectedRover = rover
        centreScrollView(for: rover)
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
    
    func createViewForRover(_ rover: Rover, atFinalposition: Bool = false ) -> RoverView {
        let unitSize = CGSize(width: gridSize, height: gridSize)
        let position = atFinalposition ? rover.finalPosition : rover.initialPosition
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
