//
//  RecordingsDateTVCell.swift
//  Voice Records
//
//  Created by MAC on 21/03/22.
//

import UIKit

class RecordingsDateTVCell: UITableViewCell {

    //MARK:- IBOutlet
    
    @IBOutlet weak var lblDate:UILabel!
    
    //MARK:- Properties
    
    var dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK:- Method
    
    func dayDifference(from interval : TimeInterval) -> String {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: interval)
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInToday(date) {
            return "Today"
        } else {
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let msgTime = Date(timeIntervalSince1970: interval)
            return dateFormatter.string(from: msgTime)
        }
    }
    
    func setData(date:String) {
        lblDate.text = dayDifference(from: TimeInterval(date) ?? 0)
    }
}
