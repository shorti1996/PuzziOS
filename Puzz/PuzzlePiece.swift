//
//  PuzzlePiece.swift
//  Puzz
//
//  Created by Wojciech Liebert on 31/10/2018.
//  Copyright © 2018 Wojciech Li. All rights reserved.
//
import UIKit
import Foundation

class PuzzlePiece : UIImageView {
    public var targetX = CGFloat(0.0)
    public var targetY = CGFloat(0.0)
    public var isDraggable = true
    
    init(frame: CGRect, targetX: CGFloat, targetY: CGFloat) {
        super.init(frame: frame)
        self.targetX = targetX
        self.targetY = targetY
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}
