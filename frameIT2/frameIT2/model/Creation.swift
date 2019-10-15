//
//  creation.swift
//  frameIT2
//
//  Created by Kalin Balabanov on 06/10/2019.
//  Copyright © 2019 Kalin Balabanov. All rights reserved.
//

import Foundation
import UIKit

class Creation {
    
    var image: UIImage
    var colorSwatch: ColorSwatch
    
    static var defaultImage: UIImage {
        return UIImage.init(named: "FrameIT-placeholder")!
    }
    
    static var defaultColorSwatch: ColorSwatch {
        return ColorSwatch.init(caption: "Simply Yellow", color: .yellow)
    }
    
    init() {
        colorSwatch = Creation.defaultColorSwatch
        image = Creation.defaultImage
    }
    
    convenience init(colorSwatch: ColorSwatch?) {
        self.init()
        // stored property initialization
        if let userColorSwatch = colorSwatch {
            self.colorSwatch = userColorSwatch
        }
    }
    
    func reset(colorSwatch: ColorSwatch?) {
        
        image = Creation.defaultImage
        if let userColorSwatch = colorSwatch {
            self.colorSwatch = userColorSwatch
        } else {
            self.colorSwatch = Creation.defaultColorSwatch
        }
    }
    
}
