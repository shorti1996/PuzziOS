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

        let pieces = splitImage(bigImage)
        
        for p in pieces {
            self.view.addSubview(p)
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.wasDragged(_:)))
            p.addGestureRecognizer(gesture)
            p.isUserInteractionEnabled = true
        }
    }

    @objc func wasDragged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        let label = gesture.view!
        
        label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func splitImage(_ imageView: UIImageView?) -> [PuzzlePiece] {
        var pieces: [PuzzlePiece] = []
        
        let image = imageView!.image
        let singlePieceWidth = imageView!.frame.size.width / CGFloat(cols)
        let singlePieceHeight = imageView!.frame.size.height / CGFloat(rows)
        
        for r in 0..<rows {
            for c in 0..<cols {
                let bounds = CGRect(x: CGFloat(r) * singlePieceWidth, y: CGFloat(c) * singlePieceHeight, width: singlePieceWidth, height: singlePieceHeight)
                let cropped = image?.cgImage?.cropping(to: bounds)
                let pieceUIImageView = PuzzlePiece(frame: bounds, targetX: bounds.minX, targetY: bounds.minY)
                pieceUIImageView.image = UIImage(cgImage: cropped!)
                
                pieces.append(pieceUIImageView)
            }
        }
        return pieces
    }

}

