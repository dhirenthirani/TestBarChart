//
//  CustomScrollView.swift
//  Charts
//
//  Created by Dhiren Thirani on 25/11/18.
//  Copyright © 2018 Dhiren Thirani. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesBegan(touches, with: event)
        }
        else {
            self.next?.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesEnded(touches, with: event)
        }
        else {
            self.next?.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesCancelled(touches, with: event)
        }
        else {
            self.next?.touchesCancelled(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragging {
            super.touchesMoved(touches, with: event)
        }
        else {
            self.next?.touchesMoved(touches, with: event)
        }
    }
}
