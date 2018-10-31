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
    
    let puzzleSnapTolerance = CGFloat(20)
    
    var bigImage: UIImageView? = nil
    var puzzleBox: UIView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigImage = self.view.viewWithTag(1) as? UIImageView
        puzzleBox = self.view.viewWithTag(1)
        
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
        let draggedPuzzleView = gesture.view! as! PuzzlePiece
        
        if (draggedPuzzleView.isDraggable) {
            draggedPuzzleView.superview?.bringSubviewToFront(draggedPuzzleView)
            draggedPuzzleView.center = CGPoint(x: draggedPuzzleView.center.x + translation.x, y: draggedPuzzleView.center.y + translation.y)
            gesture.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if (gesture.state == UIGestureRecognizer.State.ended) {
            if (abs(draggedPuzzleView.frame.minX - draggedPuzzleView.targetX) <= puzzleSnapTolerance
                && abs(draggedPuzzleView.frame.minY - draggedPuzzleView.targetY) <= puzzleSnapTolerance) {
                draggedPuzzleView.frame = CGRect(x: draggedPuzzleView.targetX, y: draggedPuzzleView.targetY, width: draggedPuzzleView.frame.width, height: draggedPuzzleView.frame.height)
                draggedPuzzleView.isDraggable = false
                draggedPuzzleView.removeGestureRecognizer(gesture)
            }
        }
    }
    
    func splitImage(_ imageView: UIImageView?) -> [PuzzlePiece] {
        var pieces: [PuzzlePiece] = []
        
        let image = imageView!.image
        let cropWidth = image!.size.width / CGFloat(cols)
        let cropHeight = image!.size.height / CGFloat(rows)
        let singlePieceWidth = imageView!.frame.size.width / CGFloat(cols)
        let singlePieceHeight = imageView!.frame.size.height / CGFloat(rows)
        
        for r in 0..<rows {
            for c in 0..<cols {
                var cropOffsetX = CGFloat(0)
                var cropOffsetY = CGFloat(0)
                var viewOffsetX = CGFloat(0)
                var viewOffsetY = CGFloat(0)
                if (r > 0) {
                    cropOffsetX = cropWidth / 3
                    viewOffsetX = singlePieceWidth / 3
                }
                if (c > 0) {
                    cropOffsetY = cropHeight / 3
                    viewOffsetY = singlePieceHeight / 3
                }
                
                let cropBounds = CGRect(x: CGFloat(r) * cropWidth - cropOffsetX, y: CGFloat(c) * cropHeight - cropOffsetY, width: cropWidth + cropOffsetX, height: cropHeight + cropOffsetY)
                let cropped = image?.cgImage?.cropping(to: cropBounds)
                
                let viewBounds = CGRect(x: imageView!.frame.minX - viewOffsetX + CGFloat(r) * singlePieceWidth, y: imageView!.frame.minY - viewOffsetY + CGFloat(c) * singlePieceHeight, width: singlePieceWidth + viewOffsetX, height: singlePieceHeight + viewOffsetY)
                let pieceUIImageView = PuzzlePiece(frame: viewBounds, targetX: viewBounds.minX, targetY: viewBounds.minY)
                pieceUIImageView.image = UIImage(cgImage: cropped!)
                
                pieces.append(pieceUIImageView)
            }
        }
        return pieces
    }

}

