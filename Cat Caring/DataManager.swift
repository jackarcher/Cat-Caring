//
//  DataManager.swift
//  Cat Caring
//
//  Created by Jack N. Archer on 5/11/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    /// The domain of our server, for easy configuration, is set here seperatly
    static let domain = "http://60.240.218.220:8000/"
    
    /// This function is used for fetching data from server by using specific api. This function is also responsible for presenting alert if the connection fails, or if the response indicates an error code. For all the error code, please refers to the server side doc.
    /// - Parameters:
    ///     - api: The api WITHOUT domain, please refer to the api documents for more information
    ///     - method: The http method, e.g: GET, POST. Please refers to the serverside doc for requirement.
    ///     - successfulHandler: The successful handler when and only when the server has a correct response. (That is status = 0,for all other case, please refers to the api doc)
    ///     - failHandler: The additional operation that helps improving user experience.
    ///     - caller: The caller of this method, which is used for pop up the alert.
    static func loadData(api: String!, method:String, parameters:Dictionary<String, Any>, successfulHandler:@escaping ((Data)->Void), failHandler:(()->Void)?, caller:UIViewController?){
        // set the activitiy icon on
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // set url
        let prepareURL = "\(domain)\(api!)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: prepareURL!)!
        
        // set session
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        defaultSession.configuration.timeoutIntervalForRequest = 5
        defaultSession.configuration.timeoutIntervalForResource = 10
        
        // set request header
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        
        var options = ["Content-Type":"application/json","User-Agent":"CatCaring/1.0"]
        
        for httpField in options.keys{
            request.addValue(options[httpField]!, forHTTPHeaderField: httpField)
        }
        // set request body
        do { try request.httpBody = JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions()) }
        catch { print("Http body generating fails.") }
        
        print("\(method):\(request.url!)")
        print("Header:\(request.allHTTPHeaderFields!)")
        print("Body:\(NSString( data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)!)")
        
        
        // data task for session
        var dataTask: URLSessionDataTask?
        
        dataTask = defaultSession.dataTask(with: request as URLRequest){
            data,respons, error in
            // async queue
            DispatchQueue.main.async{
                let alert = UIAlertController(title: "Oops", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                // error handler
                if let error = error{
                    print (error.localizedDescription)
                    alert.message = error.localizedDescription
                    failHandler?()
                    caller?.present(alert, animated: true, completion: nil)
                } else if let httpResponse = respons as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200{
                        // successufly got data
                        if api == "photo"{
                            successfulHandler(data!)
                        } else {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String:Any]
                                for j in json{
                                    print(j)
                                }
                                let status = json["status"] as! Int
                                alert.message = json["message"] as? String
                                if status == 0{
                                    successfulHandler(data!)
                                } else {
                                    // connection ok, but other problems. See server API for further info."
                                    failHandler?()
                                    caller?.present(alert, animated: true, completion: nil)
                                }
                            } catch {
                                print("error: \(error)")
                            }
                        }
                    } else if httpResponse.statusCode == 403 {
                        // just retry it!
                        if user?.id != nil && user?.pwd != nil{
                            // clear cookie in case
                            loadData(api: api, method: method, parameters: parameters, successfulHandler: successfulHandler, failHandler: failHandler, caller: caller)
                        } else {
                            // remind the user to login
                            alert.message = "You need to login first."
                            alert.addAction(UIAlertAction(title: "Login", style: .default, handler: {
                                _ in
                                caller?.tabBarController?.selectedIndex = 3
                            }))
                            caller?.present(alert, animated: true, completion: nil)
                        }
                    }else{
                        // todo alert
                        alert.message = "Could not connecte to server"
                        caller?.present(alert, animated: true, completion: nil)
                        failHandler?()
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        dataTask?.resume()
        
    }
    
}
