//
//  ViewController.swift
//  Puzz
//
//  Created by Wojciech Liebert on 31/10/2018.
//  Copyright © 2018 Wojciech Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let cols = 4
    let rows = 4
    let questionImageArray = [#imageLiteral(resourceName: "p_01")]
    var bigImage: UIImageView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigImage = self.view.viewWithTag(1) as? UIImageView
        let singlePieceRect = CGRect(x: 0, y: 0, width: bigImage!.frame.width / CGFloat(cols), height: bigImage!.frame.height / CGFloat(rows))
        
        let piece = UIImageView(frame: CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2, width: singlePieceRect.width, height: singlePieceRect.height))
        piece.image = questionImageArray[0]
        self.view.addSubview(piece)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.wasDragged(_:)))
        piece.addGestureRecognizer(gesture)
        
        piece.isUserInteractionEnabled = true
    }

    @objc func wasDragged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        let label = gesture.view!
        
        label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }

}

