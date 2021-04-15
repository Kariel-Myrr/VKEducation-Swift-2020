//
//  TopBarButton.swift
//  TabBarController
//
//  Created by Kariel Myrr on 28.10.2020.
//

import Foundation
import UIKit

class TopBarButton: UIButton {
    
    var number = 0;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTap(){
        print(#function)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleSize = titleLabel!.frame.size
        let imageSize = imageView!.frame.size
        let sumSize = CGSize(width: max(titleSize.width, imageSize.width), height: titleSize.height + imageSize.height + (bounds.height-titleSize.height - imageSize.height)/3)
        
        titleLabel?.frame = CGRect(origin: CGPoint(x : (bounds.width - titleSize.width)/2, y : (bounds.height - sumSize.height)/2 + safeAreaInsets.top + (bounds.height-titleSize.height - imageSize.height)/3), size: titleSize)
        
        imageView?.frame = CGRect(origin: CGPoint(x : (bounds.width - imageSize.width)/2, y : (bounds.height - sumSize.height)/2 - titleSize.height + safeAreaInsets.top + 10), size: imageSize)
    }
    
}

