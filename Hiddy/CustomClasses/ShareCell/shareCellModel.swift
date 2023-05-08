//
//  shareCellModel.swift
//  Hiddy
//
//  Created by Hitasoft on 15/07/19.
//  Copyright © 2019 HITASOFT. All rights reserved.
//

import UIKit

struct CellModel {
    
    var image: UIImage
    var imageData: Data?
    var imageURL: String
    var type: String

    init(image: UIImage,imageData: Data?,imageURL: String, type: String) {
        
        self.image = image
        self.imageData = imageData
        self.imageURL = imageURL
        self.type = type
    
    }
}

struct VideoCellModel {
    
    var imageData: Data?
    var imageURL: String
    var type: String
    var thumb: String?
    var localPath: String?
    
    init(imageData: Data?,imageURL: String, type: String, thumb: String?, localPath: String?) {
      
        self.imageData = imageData
        self.imageURL = imageURL
        self.type = type
        self.thumb = thumb
        self.localPath = localPath
        
    }
}
