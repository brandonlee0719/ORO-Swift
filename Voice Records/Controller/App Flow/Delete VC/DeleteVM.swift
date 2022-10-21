//
//  DeleteVM.swift
//  Voice Records
//
//  Created by MAC on 18/04/22.
//

import Foundation

class DeleteVM: BaseViewModel {
    
    //MARK:- Properties
    
    var deleteData:HomeModel!
    var dateFormatter = DateFormatter()
    
    var mediaID = ""
    
    //MARK:- Method
    
    func deleteAudio(completion:@escaping (_ isSuccess:Bool) -> Void) {
        
        let parameter = ParameterRequest()
        
        parameter.addParameter(key: ParameterRequest.userId, value: AppPrefsManager.shared.getUserID())
        parameter.addParameter(key: ParameterRequest.mediaId, value: mediaID)
        
        apiClient.deleteAudio(parameters: parameter.parameters) { (resp, respMsg, respCode, err) in
            
            guard err == nil else {
                self.errorSuccessMessage = err!
                completion(false)
                return
            }
            
            if respCode ==  ResponseStatus.success {
                self.errorSuccessMessage = respMsg!
                completion(true)
            } else {
                
                self.errorSuccessMessage = respMsg!
                completion(false)
            }
        }
    }
}
