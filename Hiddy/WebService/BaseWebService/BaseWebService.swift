//
//  BaseWebService.swift
//  HSTaxiUserApp
//
//  Created by APPLE on 20/03/18.
//  Copyright © 2018 APPLE. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
public typealias Parameters = [String: Any]

class BaseWebService: NSObject {
    // POST METHOD
    public func baseService(subURl: String, params: Parameters!, onSuccess success: @escaping (NSDictionary) -> Void, onFailure failure: @escaping (_ error: Error?) -> Void) {
        let BaseUrl = URL(string: BASE_URL+subURl)
         print("BASE URL : \(BASE_URL+subURl)")
         print("PARAMETER : \(params!)")
        if Utility().isConnectedToNetwork(){
            var header:HTTPHeaders? =  nil
            if(DBConfig().getAccessToken() != nil) {
                header = self.getHeaders()
            }
            //webservice call
            Alamofire.request(BaseUrl!, method:.post, parameters: params!, encoding: URLEncoding.httpBody, headers: header).responseJSON { response in
                //sucesss block
                let JSON = response.result.value as? NSDictionary
                switch response.result {
                case .success:
                     print("RESPONSE SUCCESS: \(JSON!)")
                    success(JSON!)
                    break
                case .failure(let error):
                     print("FAILURE RESPONSE:\(subURl) \(error.localizedDescription)")
                    if error._code == NSURLErrorTimedOut{
                       // Utility.shared.showAlert(msg: Utility.language?.value(forKey: "timed_out") as! String)
                    }else if error._code == NSURLErrorNotConnectedToInternet{
                        Utility.shared.goToOffline()
                    }else{
                     //   Utility.shared.showAlert(msg: Utility.language?.value(forKey: "server_alert") as! String)
                    }
                }
            }
        }else{
            Utility.shared.goToOffline()
        }
    }
    
    // GET METHOD
    public func getBaseService(subURl: String,onSuccess success: @escaping (NSDictionary) -> Void, onFailure failure: @escaping (_ error: Error?) -> Void) {
        let BaseUrl = URL(string: BASE_URL+subURl)
         print("BASE URL : \(BASE_URL+subURl)")
        if Utility().isConnectedToNetwork(){
            var header:HTTPHeaders? =  nil
            if(DBConfig().getAccessToken() != nil) {
                header = self.getHeaders()
            }
            //webservice call
            Alamofire.request(BaseUrl!, method:.get, parameters: nil, encoding: URLEncoding.httpBody, headers: header).responseJSON { response in
                //sucesss block
                let JSON = response.result.value as? NSDictionary
                switch response.result {
                case .success:
                     print("RESPONSE SUCCESS: \(JSON!)")
                    success(JSON!)
                    break
                case .failure(let error):
                     print("FAILURE RESPONSE:\(subURl) \(error.localizedDescription)")
                    if error._code == NSURLErrorTimedOut{
//                        Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                    }else if error._code == NSURLErrorNotConnectedToInternet{
                        Utility.shared.goToOffline()
                    }else{
//                        Utility.shared.showAlert(msg: Utility.language?.value(forKey: "server_alert") as! String)
                    }
                }
            }
        }else{
            Utility.shared.goToOffline()
        }
    }
    
    // DELETE  METHOD
    public func deleteMethod(subURl: String, params: Parameters!, onSuccess success: @escaping (NSDictionary) -> Void, onFailure failure: @escaping (_ error: Error?) -> Void) {
        let BaseUrl = URL(string: BASE_URL+subURl)
        // print("BASE URL : \(BASE_URL+subURl)")
        // print("PARAMETER : \(params!)")
        if Utility().isConnectedToNetwork(){
            var header:HTTPHeaders? =  nil
            if(DBConfig().getAccessToken() != nil) {
                header = self.getHeaders()
            }
            //webservice call
            Alamofire.request(BaseUrl!, method:.delete, parameters: params!, encoding: URLEncoding.httpBody, headers: header).responseJSON { response in
                //sucesss block
                let JSON = response.result.value as? NSDictionary
                switch response.result {
                case .success:
                    // print("RESPONSE SUCCESS: \(JSON!)")
                    success(JSON!)
                    break
                case .failure(let error):
                    // print("FAILURE RESPONSE:\(subURl) \(error.localizedDescription)")
                    if error._code == NSURLErrorTimedOut{
//                        Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "timed_out") as! String)
                    }else if error._code == NSURLErrorNotConnectedToInternet{
                        Utility.shared.goToOffline()
                    }else{
                        Utility.shared.showAlert(msg: Utility.shared.getLanguage()?.value(forKey: "server_alert") as! String)
                    }
                }
            }
        }else{
            Utility.shared.goToOffline()
        }
    }
    
   
    //MARK: http headers
    func getHeaders() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Authorization": DBConfig().getAccessToken()! as String,
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        return headers
    }
}
