//
//  ImagesCollestionViewController.swift
//  Puzz
//
//  Created by Wojciech Liebert on 02/11/2018.
//  Copyright © 2018 Wojciech Li. All rights reserved.
//

import Foundation
import UIKit

class ImagesCollectionViewController: UICollectionViewController {
    
    fileprivate let reuseIdentifier = "imageCell"
    
    let images = [#imageLiteral(resourceName: "peony_small2"), #imageLiteral(resourceName: "rose"), #imageLiteral(resourceName: "daisy"), #imageLiteral(resourceName: "gazania")]
    
    var selectedImage: UIImage?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let data = selectedImage
        if let destinationViewController = segue.destination as? ViewController {
            destinationViewController.selectedImage = data
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath)
        cell.isUserInteractionEnabled = true
        let imageView = UIImageView(frame: cell.contentView.frame)
        imageView.image = images[indexPath.row]
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        selectedImage = images[indexPath.item]
        performSegue(withIdentifier: "openImage", sender: self)
    }
}
