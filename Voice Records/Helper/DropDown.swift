//
//  DropDown.swift
//  PlugSpace
//
//  Created by MAC on 08/01/22.
//

import Foundation
import DropDown
import UIKit

extension Sequence where Iterator.Element == DropDown {
    
    func setDropdown(dropDown:DropDown ,dataArr: [String], anchorView:AnchorView) {
    
        self.forEach { (v) in
        
            v.setData(dataArr: dataArr, anchorView: anchorView)
        }
    }
}

extension DropDown {
    
    func setData(dataArr: [String], anchorView: AnchorView) {
                self.dataSource = dataArr
                self.anchorView = anchorView
                self.separatorColor = .clear
                self.clearSelection()
                self.bottomOffset = CGPoint(x: -70, y: ((self.anchorView?.plainView.bounds.height)!+10))
                self.selectionAction = { (index, item) in
        }
    }
    
    func showDropDown() {
        self.show()
    }
}
