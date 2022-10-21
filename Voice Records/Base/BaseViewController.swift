//
//  BaseViewController.swift
//  RecycleBucks
//
//  Created by MAC on 17/03/20.
//  Copyright © 2020 MAC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SVProgressHUD

class BaseViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: - VC Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - SetupUI
    
    @IBAction func onBtnBack(_ sender: UIButton) {
        backVC()
    }
    
    //MARK:- Method
    
    func setNoDataFoundView(containerView: UIView, text: String) {
        let noDataFoundViewNew = Bundle.main.loadNibNamed("NoDataFoundView", owner: nil, options: nil)?.first as! NoDataFoundView
        noDataFoundViewNew.tag = -1000
        noDataFoundViewNew.lblNoDataFound.text = text
        noDataFoundViewNew.frame.size = containerView.frame.size
        noDataFoundViewNew.clipsToBounds = false
        containerView.addSubview(noDataFoundViewNew)
    }
    
    func removeNewNoDataViewFrom(containerView: UIView) {
        for subview in containerView.subviews where subview.tag == -1000 {
            subview.removeFromSuperview()
            break
        }
    }
}
