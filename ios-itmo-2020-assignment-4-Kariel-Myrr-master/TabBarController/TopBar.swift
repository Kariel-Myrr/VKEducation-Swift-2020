//
//  TopBar.swift
//  TabBarController
//
//  Created by Kariel Myrr on 28.10.2020.
//

import Foundation
import UIKit

class TopBar : UIControl{
    
    var buttons : [TopBarButton] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    init(frame: CGRect, buttons : [TopBarButton]) {
        super.init(frame: frame)

        for i in buttons {
            self.buttons.append(i)
            addSubview(i)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        let sideSlideButton = self.bounds.width/CGFloat(buttons.count);
        var j = 0;
        for i in buttons {
            i.frame = CGRect(x: sideSlideButton*CGFloat(j), y: 0, width: sideSlideButton, height: bounds.height)
            addSubview(i)
            j += 1;
        }
    }
    
    
    
    
    
}

