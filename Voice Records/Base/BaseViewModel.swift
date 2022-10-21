//
//  BaseViewModel.swift
//  RecycleBucks
//
//  Created by iMac on 24/06/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import Foundation

class BaseViewModel {
    
    // MARK: - Variable
    lazy var apiClient = APIClient()
    var errorSuccessMessage = ""
}
