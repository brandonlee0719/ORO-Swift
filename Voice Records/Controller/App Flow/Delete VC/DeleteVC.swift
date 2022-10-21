//
//  DeleteVC.swift
//  Voice Records
//
//  Created by MAC on 22/03/22.
//

import UIKit

class DeleteVC: BaseViewController {

    //MARK:- Outlets
    
    @IBOutlet weak var lblRecordingName:UILabel!
    @IBOutlet weak var lblRecordingDate:UILabel!
    
    @IBOutlet weak var btnDelete:UIButton!
    @IBOutlet weak var btnKeepIt:UIButton!
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
		setData()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Properties
    
    let viewModel = DeleteVM()
    
    //MARK:- Method

    func setUpUI() {
        btnDelete.cornerRadius = 8
    }
      
	func setData() {
		lblRecordingName.text = viewModel.deleteData.title
		lblRecordingDate.text = dayDifference(from:  TimeInterval(viewModel.deleteData.datetime) ?? 0)
	}
	
	func dayDifference(from interval : TimeInterval) -> String {
			viewModel.dateFormatter.dateFormat = "EEE, dd MMM yyyy"
			let msgTime = Date(timeIntervalSince1970: interval)
			return viewModel.dateFormatter.string(from: msgTime)
	}
	
	//MARK:- APi Calling
    func callApiDeleteAudio() {
		
		viewModel.mediaID = String(viewModel.deleteData.mediaId)
		
        viewModel.deleteAudio { [self] (isSuccess) in
            if isSuccess {
                 
                AppDelegate.shared.window?.rootViewController!.showToast(message: viewModel.errorSuccessMessage, font: UIFont(name: AppFont.RoobertRegular, size: setCustomFont(18)) ?? UIFont())
                backVC()
             } else {
                alertWith(message: viewModel.errorSuccessMessage)
            }
        }
    }
            
    //MARK:- IBAction
             
    @IBAction func btnDelete(_ sender:UIButton) {
        callApiDeleteAudio()
    }
    
    @IBAction func btnKeepIt(_ sender:UIButton) {
        backVC()
    }
}
