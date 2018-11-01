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
                if (c > 0) {
                    cropOffsetX = cropWidth / 3
                    viewOffsetX = singlePieceWidth / 3
                }
                if (r > 0) {
                    cropOffsetY = cropHeight / 3
                    viewOffsetY = singlePieceHeight / 3
                }
                
                let cropBounds = CGRect(x: CGFloat(c) * cropWidth - cropOffsetX, y: CGFloat(r) * cropHeight - cropOffsetY, width: cropWidth + cropOffsetX, height: cropHeight + cropOffsetY)
                let cropped = image?.cgImage?.cropping(to: cropBounds)
                
                let viewBounds = CGRect(x: imageView!.frame.minX - viewOffsetX + CGFloat(c) * singlePieceWidth, y: imageView!.frame.minY - viewOffsetY + CGFloat(r) * singlePieceHeight, width: singlePieceWidth + viewOffsetX, height: singlePieceHeight + viewOffsetY)
                let pieceUIImageView = PuzzlePiece(frame: viewBounds, targetX: viewBounds.minX, targetY: viewBounds.minY)
                pieceUIImageView.image = UIImage(cgImage: cropped!)
                
                let bumpSize = singlePieceHeight / 4
                let path = CGMutablePath()
                path.move(to: CGPoint(x: viewOffsetX, y: viewOffsetY))
                if (r == 0) {
                    // top side piece
                    path.addLine(to: CGPoint(x: pieceUIImageView.frame.width, y: viewOffsetY))
                } else {
                    // top bump
                    path.addLine(to: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) / 3, y: viewOffsetY))
                    path.addCurve(to: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) / 6, y: viewOffsetY) ,
                                  control1: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) / 6 * 5, y: viewOffsetY - bumpSize),
                                  control2: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) / 6, y: viewOffsetY - bumpSize))
//                    path.cubicTo(
//                    offsetX + (pieceBitmap.getWidth() - offsetX) / 6,
//                    offsetY - bumpSize,
//                    offsetX + (pieceBitmap.getWidth() - offsetX) / 6 * 5,
//                    offsetY - bumpSize,
//                    offsetX + (pieceBitmap.getWidth() - offsetX) / 3 * 2,
//                    offsetY);
                    
                    path.addLine(to: CGPoint(x: pieceUIImageView.frame.width, y: viewOffsetY))
                }
                if (c == cols - 1) {
                    // right side piece
                    path.addLine(to: CGPoint(x: pieceUIImageView.frame.width, y: -pieceUIImageView.frame.height))
                } else {
                    // right bump
                    path.addLine(to: CGPoint(x: pieceUIImageView.frame.width, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 1 / 3)))
                    path.addCurve(to: CGPoint(x: pieceUIImageView.frame.width, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 2 / 3)),
                                  control1: CGPoint(x: pieceUIImageView.frame.width - bumpSize, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 1 / 6)),
                                  control2: CGPoint(x: pieceUIImageView.frame.width - bumpSize, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 5 / 6 )))
//                    path.cubicTo(
//                        pieceBitmap.getWidth() - bumpSize,
//                        offsetY + (pieceBitmap.getHeight() - offsetY) / 6,
//                        pieceBitmap.getWidth() - bumpSize,
//                        offsetY + (pieceBitmap.getHeight() - offsetY) / 6 * 5,
//                        pieceBitmap.getWidth(),
//                        offsetY + (pieceBitmap.getHeight() - offsetY) / 3 * 2);
                    path.addLine(to: CGPoint(x: pieceUIImageView.frame.width, y: -pieceUIImageView.frame.height))
                }
                if (r == rows - 1) {
                    // bottom side piece
                    path.addLine(to: CGPoint(x: viewOffsetX, y: -pieceUIImageView.frame.height))
                } else {
                    // bottom bump
                    path.addLine(to: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) * 2 / 3, y: -pieceUIImageView.frame.height))
                    path.addCurve(to: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) * 1 / 3, y: -pieceUIImageView.frame.height),
                                  control1: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) * 5 / 6, y: -(pieceUIImageView.frame.height - bumpSize)),
                                  control2: CGPoint(x: viewOffsetX + (pieceUIImageView.frame.width - viewOffsetX) * 1 / 6, y: -(pieceUIImageView.frame.height - bumpSize)))

//                    path.cubicTo(
//                        offsetX + (pieceBitmap.getWidth() - offsetX) / 6 * 5,
//                        pieceBitmap.getHeight() - bumpSize,
//                        offsetX + (pieceBitmap.getWidth() - offsetX) / 6,
//                        pieceBitmap.getHeight() - bumpSize,
//                        offsetX + (pieceBitmap.getWidth() - offsetX) / 3,
//                        pieceBitmap.getHeight());

                    path.addLine(to: CGPoint(x: viewOffsetX, y: -pieceUIImageView.frame.height))
                }
                if (c == 0) {
                    // left side piece
                    // OK: closing this path with draw a straight line
                } else {
                    // left bump
                    path.addLine(to: CGPoint(x: viewOffsetX, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 2 / 3)))
                    path.addCurve(to: CGPoint(x: viewOffsetX, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 1 / 3)),
                                  control1: CGPoint(x: viewOffsetX - bumpSize, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 5 / 6)),
                                  control2: CGPoint(x: viewOffsetX - bumpSize, y: -(-viewOffsetY + (pieceUIImageView.frame.height - viewOffsetY) * 1 / 6)))
//                    path.cubicTo(
//                        offsetX - bumpSize,
//                        offsetY + (pieceBitmap.getHeight() - offsetY) / 6 * 5,
//                        offsetX - bumpSize,
//                        offsetY + (pieceBitmap.getHeight() - offsetY) / 6,
//                        offsetX,
//                        offsetY + (pieceBitmap.getHeight() - offsetY) / 3);
                }
                path.closeSubpath()
                let uiPath = UIBezierPath(cgPath: path)
                let mask = CAShapeLayer()
                mask.path = path
//                mask.frame = CGRect(origin: CGPoint(x: pieceUIImageView.frame.minX - viewOffsetX, y: -viewOffsetY), size: mask.frame.size)
//                mask.frame = CGRect(x: pieceUIImageView.frame.minX - (bigImage?.frame.minX)!, y: pieceUIImageView.frame.minY + (bigImage?.frame.minY)!, width: path.boundingBox.width, height: path.boundingBox.height)
//                mask.frame = CGRect(x: pieceUIImageView.frame.minX, y: -pieceUIImageView.frame.maxY, width: 0, height: 0)
//                path.append(UIBezierPath(rect: self.bounds))
//                uiPath.apply(CGAffineTransform(translationX: 0, y: pieceUIImageView.frame.maxY - 20))
                uiPath.apply(CGAffineTransform(scaleX: 1, y: -1))
//                mask.path = uiPath.cgPath
                mask.fillRule = CAShapeLayerFillRule.evenOdd

                // Add the mask to the view
//                pieceUIImageView.layer.mask = mask
                pieceUIImageView.mask(withPath: uiPath, inverse: false)
                pieces.append(pieceUIImageView)
//                return pieces
            }
        }
        return pieces
    }

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

