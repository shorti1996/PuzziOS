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
        puzzleBox = self.view.viewWithTag(2)
        
        let pieces = splitImage(bigImage)
        
        for p in pieces {
            self.view.addSubview(p)
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.wasDragged(_:)))
            p.addGestureRecognizer(gesture)
            p.isUserInteractionEnabled = true
//            let randomPositionInPuzzleBox =
            p.frame = CGRect(origin: randomizePosition(viewFrame: p.frame, parentViewFrame: (puzzleBox?.frame)!), size: p.frame.size)
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
                if (c > 0) {
                    cropOffsetX = cropWidth / 3
                    viewOffsetX = singlePieceWidth / 3
                }
                if (r > 0) {
                    cropOffsetY = cropHeight / 3
                    viewOffsetY = singlePieceHeight / 3
                }
                let bumpSize = singlePieceHeight / 4
                
                let cropBounds = CGRect(x: CGFloat(c) * cropWidth - cropOffsetX, y: CGFloat(r) * cropHeight - cropOffsetY, width: cropWidth + cropOffsetX, height: cropHeight + cropOffsetY)
                let viewBounds = CGRect(x: imageView!.frame.minX - viewOffsetX + CGFloat(c) * singlePieceWidth, y: imageView!.frame.minY - viewOffsetY + CGFloat(r) * singlePieceHeight, width: singlePieceWidth + viewOffsetX, height: singlePieceHeight + viewOffsetY)
                
                let cropped = image?.cgImage?.cropping(to: cropBounds)
                let pieceUIImageView = PuzzlePiece(frame: viewBounds, targetX: viewBounds.minX, targetY: viewBounds.minY)
                pieceUIImageView.image = UIImage(cgImage: cropped!)
                
                let path = makePuzzlePath(r: r, c: c, rows: rows, cols: cols, pieceFrame: pieceUIImageView.frame, bumpSize: bumpSize, singlePieceHeight: singlePieceHeight, viewOffsetX: viewOffsetX, viewOffsetY: viewOffsetY)
                let uiPath = UIBezierPath(cgPath: path)
                let mask = CAShapeLayer()
                uiPath.apply(CGAffineTransform(scaleX: 1, y: -1))
                if(r > 0) {
                    uiPath.apply(CGAffineTransform(translationX: 0, y: singlePieceHeight - viewOffsetY))
                }
                mask.path = uiPath.cgPath
                mask.fillRule = CAShapeLayerFillRule.evenOdd
                pieceUIImageView.layer.mask = mask
                pieces.append(pieceUIImageView)
//                return pieces
            }
        }
        return pieces
    }

}

func makePuzzlePath(r: Int,
                    c: Int,
                    rows: Int,
                    cols: Int,
                    pieceFrame: CGRect,
                    bumpSize: CGFloat,
                    singlePieceHeight: CGFloat,
                    viewOffsetX: CGFloat,
                    viewOffsetY: CGFloat) -> CGPath {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: viewOffsetX, y: viewOffsetY))
    if (r == 0) {
        // top side piece
        path.addLine(to: CGPoint(x: pieceFrame.width, y: viewOffsetY))
    } else {
        // top bump
        path.addLine(to: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 1 / 3, y: viewOffsetY))
        path.addCurve(to: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 2 / 3, y: viewOffsetY) ,
                      control1: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 1 / 6, y: viewOffsetY + bumpSize),
                      control2: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 5 / 6, y: viewOffsetY + bumpSize))
        path.addLine(to: CGPoint(x: pieceFrame.width, y: viewOffsetY))
    }
    if (c == cols - 1) {
        // right side piece
        path.addLine(to: CGPoint(x: pieceFrame.width, y: -pieceFrame.height))
    } else {
        // right bump
        path.addLine(to: CGPoint(x: pieceFrame.width, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 1 / 3)))
        path.addCurve(to: CGPoint(x: pieceFrame.width, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 2 / 3)),
                      control1: CGPoint(x: pieceFrame.width - bumpSize, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 1 / 6)),
                      control2: CGPoint(x: pieceFrame.width - bumpSize, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 5 / 6 )))
        path.addLine(to: CGPoint(x: pieceFrame.width, y: -singlePieceHeight + viewOffsetY))
    }
    if (r == rows - 1) {
        // bottom side piece
        path.addLine(to: CGPoint(x: viewOffsetX, y: -pieceFrame.height + viewOffsetY))
    } else {
        // bottom bump
        path.addLine(to: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 2 / 3, y: -singlePieceHeight + viewOffsetY))
        path.addCurve(to: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 1 / 3, y: -singlePieceHeight + viewOffsetY),
                      control1: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 5 / 6, y: -singlePieceHeight + viewOffsetY + bumpSize),
                      control2: CGPoint(x: viewOffsetX + (pieceFrame.width - viewOffsetX) * 1 / 6, y: -singlePieceHeight + viewOffsetY + bumpSize))
        path.addLine(to: CGPoint(x: viewOffsetX, y: -singlePieceHeight + viewOffsetY))
    }
    if (c == 0) {
        // left side piece
        // OK: closing this path with draw a straight line
    } else {
        // left bump
        path.addLine(to: CGPoint(x: viewOffsetX, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 2 / 3)))
        path.addCurve(to: CGPoint(x: viewOffsetX, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 1 / 3)),
                      control1: CGPoint(x: viewOffsetX - bumpSize, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 5 / 6)),
                      control2: CGPoint(x: viewOffsetX - bumpSize, y: -(-viewOffsetY + (pieceFrame.height - viewOffsetY) * 1 / 6)))
    }
    path.closeSubpath()
    return path
}

func randomizePosition(viewFrame: CGRect, parentViewFrame: CGRect) -> CGPoint {
    let minX = parentViewFrame.minX
    let minY = parentViewFrame.minY
    let maxX = parentViewFrame.maxX - viewFrame.width
    let maxY = parentViewFrame.maxY - viewFrame.height
    
    return CGPoint(x: CGFloat.random(in: minX..<maxX),
                   y: CGFloat.random(in: minY..<maxY))
}

extension UIView {
    
    func mask(withRect rect: CGRect, inverse: Bool = false) {
        let path = UIBezierPath(rect: rect)
        let maskLayer = CAShapeLayer()
        
        if inverse {
            path.append(UIBezierPath(rect: self.bounds))
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
    
    func mask(withPath path: UIBezierPath, inverse: Bool = false) {
        let path = path
        let maskLayer = CAShapeLayer()
        
        if inverse {
            path.append(UIBezierPath(rect: self.bounds))
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
}

