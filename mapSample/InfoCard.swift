//
//  InfoCard.swift
//  mapSample
//
//  Created by 平塚 俊輔 on 2016/03/14.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import UIKit

public protocol InfoCardDelegate : class {
    

    
}


class InfoCard: UIView {

    var x:CGFloat! = 0
    var y:CGFloat! = 0
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    weak var delegate:InfoCardDelegate?
    
    class func instance() -> InfoCard {
        return UINib(nibName: "InfoCard", bundle: nil).instantiateWithOwner(self, options: nil)[0] as! InfoCard
    }
    
    /**
     情報をセット
     
     - parameter dicInfo: <#dicInfo description#>
     */
    func setInfomation(loc:NSDictionary){
        self.titleLabel.text = loc.objectForKey("city") as? String ?? ""
        self.descLabel.text = loc.objectForKey("town") as? String ?? ""
        let strx = loc.objectForKey("x") as? String ?? "0"
        let stry = loc.objectForKey("y") as? String ?? "0"
        self.x = CGFloat(NSString(string: strx).floatValue)
        self.y = CGFloat(NSString(string: stry).floatValue)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "clickItem:")
        tapGesture.numberOfTapsRequired = 1
        self.userInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
        
    }
    
    func clickItem(tapGestureRecognizer: UITapGestureRecognizer) {
        
    }
    
}
