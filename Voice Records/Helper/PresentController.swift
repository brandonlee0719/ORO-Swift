//
//  PresentController.swift
//  Voice Records
//
//  Created by MAC on 24/03/22.
//

import Foundation
import FittedSheets

class PresentController: NSObject {
    
    //MARK:- Properties
    
    var options = SheetOptions()
    static let shared = PresentController()
    var sheetController : SheetViewController!
    
    //MARK:-
    override init() {
        options.presentingViewCornerRadius = 20
        options.useFullScreenMode = true
    }
    
    //MARK:- Method
 
    func presentVC<T: UIViewController>(controller: T.Type,vc:UIViewController, marginTop:CGFloat)
    {
        let PresentVc = UIStoryboard.instantiateVC(controller, .Main)
         sheetController = SheetViewController(controller: PresentVc,sizes: [.marginFromTop(marginTop)],options: options)
        vc.present(sheetController, animated: false, completion: nil)
    }
    
    func presentCustomVC<T: UIViewController>(controller: T.Type, vc:UIViewController, height:CGFloat) {
        let PresentVc = UIStoryboard.instantiateVC(controller, .Main)
        sheetController = SheetViewController(controller: PresentVc,sizes: [.fixed(height)],options: options)
        vc.present(sheetController, animated: false, completion: nil)
    }
}
