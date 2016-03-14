//
//  SampleApi.swift
//  mapSample
//
//  Created by 平塚 俊輔 on 2016/03/11.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum SampleApiError: ErrorType {
    case NoResponse
    case Bad
}

class SampleApi : NSObject{
    
    
    static let sharedAPI = SampleApi()
    
    /**
     ワークリスト
     
     :param: param         param
     :param: bool_loadnext 次のページを読み込む
     
     :returns: Observable<NSArray>
     */
    func getAddressInfo(param:NSDictionary) -> Observable<NSArray>{
        //URL作って
        let param_str = param.urlEncodedString()
        let url_str = "http://geoapi.heartrails.com/api/json?"+param_str
        
        //いろいろする
        let url = NSURL(string: url_str)!
        let request = NSURLRequest(URL: url)
        return NSURLSession.sharedSession().rx_response(request)
            .observeOn(Dependencies.sharedDependencies.backgroundWorkScheduler)
            .map { data, response in
                guard let httpResponse = response as? NSHTTPURLResponse else {
                    throw SampleApiError.NoResponse
                }
                
                if httpResponse.statusCode != 200 {
                    throw SampleApiError.Bad
                }
                return try self.parseJSON(data)
            }
            .observeOn(Dependencies.sharedDependencies.mainScheduler)
    }
    
    /**
     通常用のワークリスト
     
     :param: json <#json description#>
     
     :returns: <#return value description#>
     */
    private func parseJSON(json: NSData) throws -> NSArray {
        guard let dict = try NSJSONSerialization.JSONObjectWithData(json, options:NSJSONReadingOptions.AllowFragments) as? NSDictionary else{
            print("Can't find results")
            return NSArray()
            
        }
        
        guard let entries = dict.objectForKey("response") as? NSDictionary else {
            print("Can't find results")
            return NSArray()
        }
        
        guard let locations = entries.objectForKey("location") as? NSArray else {
            print("Can't find results")
            return NSArray()
        }
        
        
        print(entries)
        
        return locations
    }
    
}

extension NSDictionary{
    func urlEncodedString() -> String {
        
        let parts:NSMutableArray = NSMutableArray()
        for key in self.allKeys {
            
            let sKey = key as! String
            let value:String = self.objectForKey(key) as! String
            let eValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let part:String! = (sKey+"="+eValue) as String!
            parts.addObject(part)
        }
        return parts.componentsJoinedByString("&")
    }
    
}