//
//  RecordingsTVCell.swift
//  Voice Records
//
//  Created by MAC on 21/03/22.
//

import UIKit
import DropDown

protocol RecordingsTVCellDelegate {
    func btnClick(action:ActionType, cell:RecordingsTVCell)
}

class RecordingsTVCell: UITableViewCell {

    //MARK:- IBOutlets
    
    @IBOutlet weak var lblAudioRecord:UILabel!
    @IBOutlet weak var lblAudioRecordName:UILabel!
    @IBOutlet weak var lblAudioRecordTime:UILabel!
    @IBOutlet weak var lblAudioRecordDate:UILabel!
    
    @IBOutlet weak var btnPlay:UIButton!
    @IBOutlet weak var btnMenu:UIButton!
    
    @IBOutlet weak var bgPlay:UIView!
    @IBOutlet weak var bgView:UIView!
    
    @IBOutlet weak var imgFavorite:UIImageView!
    
    //MARK:- Properties
    
     let menuDropDown = DropDown()
    var menuArr = ["Edit","Favourite","Delete","Share"]
    
    var delegate:RecordingsTVCellDelegate!
    var dateFormatter = DateFormatter()
    
    //MARK:-
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    //MARK:- Method
    
    func setUpUI() {
        btnPlay.cornerRadius = 8
        bgView.cornerRadius = 8
        
        setAfter { [self] in
            bgView.setShadowView(color: AppColor.Black, opacity: 0.2, offset: CGSize(width: 1, height: 0.0), radius: 2)
        }
    }
    
    func setFavorite(data:HomeModel) {
        
        data.isFavorite = data.isFavorite == "0" ? "1" : "0"
        
        menuArr[1] = data.isFavorite == "0" ? "Favourite" : "Unfavorite"
        menuDropDown.setData(dataArr: menuArr, anchorView: btnMenu)
        menuDropDown.selectionAction = { [self] (index, item) in
            delegate.btnClick(action: ActionType(rawValue: item)!, cell: self)
        }
        imgFavorite.isHidden = data.isFavorite == "0" ? true : false
    }
    
    func setData(data:HomeModel) {
        lblAudioRecordName.text = data.title
        lblAudioRecordTime.text = data.time
        lblAudioRecordDate.text = dayDifference(from: TimeInterval(data.datetime) ?? 0)
        imgFavorite.isHidden = data.isFavorite == "0" ? true : false
        menuArr[1] = data.isFavorite == "0" ? "Favourite" : "Unfavorite"
        menuDropDown.setData(dataArr: menuArr, anchorView: btnMenu)
        menuDropDown.selectionAction = { [self] (index, item) in
            delegate.btnClick(action: ActionType(rawValue: item)!, cell: self)
        }
    }
    
    func setPlayAudio(isPlay:Bool) {
        btnPlay.setImage(isPlay ? UIImage(named: "ic_Playing") : UIImage(named: "ic_Play"), for: .normal)
    }
    
    func dayDifference(from interval : TimeInterval) -> String {

            dateFormatter.dateFormat = "MMM dd"
            let msgTime = Date(timeIntervalSince1970: interval)
            return dateFormatter.string(from: msgTime)
    }
    
    //MARK:- IBAction
    @IBAction func clickBtnMenu(_ sender: UIButton) {
        menuDropDown.showDropDown()
    }
}
