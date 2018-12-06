//
//  MarkerView.swift
//  Delivery
//
//  Created by ThuyenBV on 12/2/18.
//  Copyright © 2018 Buvaty. All rights reserved.
//

import UIKit

class MarkerView: UIView {
    
    init(index: Int) {
        let frame = CGRect(x: 0, y: 0, width: 30, height: 37)
        super.init(frame: frame)
        
        let backgroundImageView = UIImageView(frame: frame)
        backgroundImageView.backgroundColor = UIColor.clear
        backgroundImageView.image = UIImage(named: "icon_marker")
        
        let indexLabel = UILabel(frame: frame)
        indexLabel.backgroundColor = UIColor.clear
        indexLabel.textColor = UIColor.white
        indexLabel.text = String(index)
        indexLabel.textAlignment = .center
        
        self.addSubview(backgroundImageView)
        self.addSubview(indexLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
