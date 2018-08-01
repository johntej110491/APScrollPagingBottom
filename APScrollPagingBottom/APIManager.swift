//
//  WebService.swift
//  AlamoFire_WebService
//
//  Created by admin on 22/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import SystemConfiguration
import Alamofire
class WebService: NSObject {
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    //MARK:
    //MARK: API Without Secureity Parameter
    
    //int_hud = 1.Show/Hide 2. NoShow/NoHide 3. Show/NoHide 4. NoShow/Hide
    
    func callAPIBYPOST(parameter:NSDictionary,url:String,int_hud : Int, OnResultBlock: @escaping (_ dict: NSDictionary,_ status:String) -> Void) {
        
        if int_hud == 1 || int_hud == 3 {
            
          //  KRProgressHUD.show(message: "Loading...")
            
        }
        
        if !isInternetAvailable() {
            
            let dic = NSMutableDictionary.init()
            dic.setValue("No Internet Connection, try later!", forKey: "message")
            dic.setValue("false", forKey: "status")
            OnResultBlock(dic,"failure")
            if int_hud == 1 || int_hud == 4{
               // KRProgressHUD.dismiss()
            }
        }
        else
        {
           // print(parameter)
            
            request(url, method: .post, parameters: parameter as? Parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
           
                if int_hud == 1 || int_hud == 4 {
                   // KRProgressHUD.dismiss()
                }
                
               // print("response === \(response)")
                
               // print(response.result.value)
                
                switch(response.result) {
                    
                case .success(_):
                    if let data = response.result.value {
                        //print(data)
                        //    let dictdata = NSMutableDictionary()
                        //  dictdata.setValue(data, forKey: "data")
                        OnResultBlock((data as! NSDictionary) ,"Success")
                    }
                    
                    break
                    
                case .failure(_):
                    
                    print(response.result.error)
                    let dic = NSMutableDictionary.init()
                    dic .setValue("Connection Time Out ", forKey: "message")
                    OnResultBlock(dic,"failure")
                    break
                }
            }
        }
        
    }
    


    func callAPIWithImage(parameter:NSDictionary,url:String,image:UIImage,imageKeyName:String,int_hud : Int,OnResultBlock: @escaping (_ dict: NSDictionary,_ status:String) -> Void){
        
        print("parameter:-\(parameter),url:-\(url),imageKeyName:-\(imageKeyName)")
        
        if !isInternetAvailable() {
            let dic = NSMutableDictionary.init()
            dic.setValue("No Internet Connection, try later!", forKey: "message")
            dic.setValue("false", forKey: "status")
            OnResultBlock(dic,"failure")
            
        } else {
        

            upload(multipartFormData: { (multiPartFormData:MultipartFormData) in
                
                if  let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    let fileName = String(format: "%f.jpg", NSDate.init().timeIntervalSince1970)
                    multiPartFormData.append(imageData, withName: imageKeyName, fileName:fileName , mimeType: "image/jpeg")
                }
                
                for (key, value) in parameter {
                    
                    print("---key: \(key)---","----value: \(value)")
                    
                    multiPartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key as! String)
                }
                
            }, to: url, method: .post) { (encodingResult:SessionManager.MultipartFormDataEncodingResult) in
                
                switch (encodingResult){
                    
                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                    
                    ///--------STRING----------

//                    upload.responseString(completionHandler: { (response) in
//                        print(response.response?.statusCode) // URL response
//                        print(response.result.value)   // result of response serialization
//
//                        if let JSON = response.result.value {
//                            OnResultBlock(JSON as! NSDictionary,"Success")
//                        }
//                    })
                    
                    
                    
                    
                    ///--------JSON----------
                    upload.responseJSON { response in
                        print(response.response?.statusCode) // URL response
                        print(response.result.value)   // result of response serialization
                        
                        if let JSON = response.result.value {
                            OnResultBlock(JSON as! NSDictionary,"Success")
                        }
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                    let dic = NSMutableDictionary.init()
                    dic.setValue("Connection Time Out ", forKey: "message")
                    OnResultBlock(dic,"failure")
                }
            }
        }
    }
    
    //MARK:
    //MARK: Get Device ID
    func get_DeviceID() -> String {
        
        let device = UIDevice.current
        
        let str_deviceID = device.identifierForVendor?.uuidString
        
        return str_deviceID!
    }
    
    
    /*
     //MARK:
     //MARK: API With Secureity Parameter
     func callSecurityAPI(parameter:NSDictionary,url:String,OnResultBlock: @escaping (_ dict: NSDictionary,_ status:String) -> Void) {
     
     let r = Reachability(hostname: "www.google.com")
     
     if r?.currentReachabilityStatus != Reachability.NetworkStatus.reachableViaWiFi && r?.currentReachabilityStatus==Reachability.NetworkStatus.reachableViaWWAN {
     
     let dic = NSMutableDictionary.init()
     dic.setValue("No Internet Connection, try later!", forKey: "message")
     dic.setValue("false", forKey: "status")
     
     OnResultBlock(dic,"failure")
     }
     else
     {
     let finalParameter = self.addSecurity_Parameter(parameter: parameter as! NSMutableDictionary)
     
     request(url, method: .post, parameters: finalParameter as? Parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
     
     switch(response.result) {
     
     case .success(_):
     if let data = response.result.value{
     OnResultBlock(data as! NSDictionary,"Success")
     }
     break
     
     case .failure(_):
     print(response.result.error)
     let dic = NSMutableDictionary.init()
     dic .setValue("Connection Time Out ", forKey: "message")
     OnResultBlock(dic,"failure")
     break
     
     }
     
     }
     
     }
     
     }
     
     func callAPIWithSecurity_Image(parameter:NSDictionary,url:String,image:UIImage,imageName:String,OnResultBlock: @escaping (_ dict: NSDictionary,_ status:String) -> Void){
     
     let r = Reachability(hostname: "www.google.com")
     
     if r?.currentReachabilityStatus != Reachability.NetworkStatus.reachableViaWiFi && r?.currentReachabilityStatus==Reachability.NetworkStatus.reachableViaWWAN {
     
     let dic = NSMutableDictionary.init()
     dic.setValue("No Internet Connection, try later!", forKey: "message")
     dic.setValue("false", forKey: "status")
     OnResultBlock(dic,"failure")
     }
     else
     {
     let finalParameter = self.addSecurity_Parameter(parameter: parameter as! NSMutableDictionary)
     
     upload(multipartFormData: { (multiPartFormData:MultipartFormData) in
     
     if  let imageData = UIImageJPEGRepresentation(image, 0.5) {
     let fileName = String(format: "%f.jpeg", NSDate.init().timeIntervalSince1970)
     multiPartFormData.append(imageData, withName: imageName, fileName: fileName, mimeType: "image/jpeg")
     }
     
     for (key, value) in finalParameter {
     multiPartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key as! String)
     }
     
     }, to: url) { (encodingResult:SessionManager.MultipartFormDataEncodingResult) in
     
     switch (encodingResult){
     
     case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
     upload.responseJSON { response in
     
     print(response.request)  // original URL request
     print(response.response) // URL response
     print(response.data)     // server data
     print(response.result)   // result of response serialization
     
     if let JSON = response.result.value
     {
     OnResultBlock(JSON as! NSDictionary,"Success")
     }
     
     }
     
     case .failure(let encodingError):
     
     print(encodingError)
     let dic = NSMutableDictionary.init()
     dic .setValue("Connection Time Out ", forKey: "message")
     OnResultBlock(dic,"failure")
     
     }
     
     }
     
     }
     
     }
     
     
     
     //MARK:
     //MARK: Get Current Time
     func get_currentTime() -> String
     {
     let timeFormat = DateFormatter.init()
     timeFormat.dateFormat = "HH:mm:ss"
     return timeFormat.string(from: Date.init())
     
     }
     
     //MARK:
     //MARK: Get Current Time
     func addSecurity_Parameter(parameter:NSMutableDictionary) -> NSDictionary
     {
     let strTimeStamp = self.get_currentTime()
     let strDeviceType = "2"
     let str_Token = String.init(format: "%@%@%@%@", "masterkey","123456789",strDeviceType,strTimeStamp)
     let str_md5 = str_Token.md5
     
     parameter.setValue("123456789", forKey: "user_device_token")
     parameter.setValue(strDeviceType, forKey: "user_device_type")
     parameter.setValue(strTimeStamp, forKey: "timestamp")
     parameter.setValue(str_md5, forKey: "md5_key")
     
     return parameter
     }
     */
}
/*
 //MARK:
 //MARK: MD5 Generate
 extension String  {
 var md5: String! {
 let str = self.cString(using: String.Encoding.utf8)
 let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
 let digestLen = Int(CC_MD5_DIGEST_LENGTH)
 let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
 
 CC_MD5(str!, strLen, result)
 
 let hash = NSMutableString()
 for i in 0..<digestLen {
 hash.appendFormat("%02x", result[i])
 }
 
 result.deallocate(capacity: digestLen)
 
 return String(format: hash as String)
 }
 }
 */


//How to use api
/*
 func call_LoginAPI(){
 
 let dict = NSMutableDictionary()
 
 KRProgressHUD.show(message: "Loading...")
 
 
 APIManager.callAPIBYPOST(parameter: dict, url: "https://test.quickpassweb.com/qpwsmobile/qpwwebservices.asmx/wsLoginMobile?usuario=usu&password=pass&login=admindemo&passlogin=1&idempresa=0") { (response, status) in
 print(response)
 if status == "Success"
 {
 Toast(text: "Registration Success.").show()
 KRProgressHUD.dismiss()
 }
 else
 {
 KRProgressHUD.dismiss()
 
 }
 }
 
 }
 */

