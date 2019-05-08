//
//  RoverView.swift
//  Mars Rover
//
//  Created by Antonio Yip on 8/05/19.
//

import UIKit

class RoverView: UIImageView {

    var rover: Rover!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    init(rover: Rover) {
        self.rover = rover
        super.init(image: UIImage(imageLiteralResourceName: "rover-top"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
