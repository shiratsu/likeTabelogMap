//
//  DropDownTextField.swift
//  mapSample
//
//  Created by 平塚 俊輔 on 2016/03/30.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import UIKit
import GoogleMaps
// MARK: Animation Style Enum
public enum DropDownAnimationStyle {
    case Basic
    case Slide
    case Expand
    case Flip
}

// MARK: Dropdown Delegate
public protocol DropDownTextFieldDataSourceDelegate: NSObjectProtocol {
    func searchData(searchText:String)
}


public class DropDownTextField: UITextField {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    weak var dataSourceDelegate: DropDownTextFieldDataSourceDelegate?
    var dropDownTableView: UITableView!
    var rowHeight:CGFloat = 50
    var dropDownTableViewHeight: CGFloat = 150
    private var heightConstraint: NSLayoutConstraint!
    public var animationStyle: DropDownAnimationStyle = .Basic
    public typealias TableData = [GMSAutocompletePrediction]
//    var aryPlace:[GMSAutocompletePrediction] = []
    var aryData: [GMSAutocompletePrediction] = []
    
    // MARK: Init Methods
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    
    // MARK: Setup Methods
    private func setupTextField() {
        addTarget(self, action: "editingChanged:", forControlEvents:.EditingChanged)
//        setUpTable()
    }

    
    func setUpTable(){
        if dropDownTableView == nil {
            
            dropDownTableView = UITableView(frame: CGRect(x:0,y:0,width: self.frame.width,height: dropDownTableViewHeight), style: .Grouped)
            dropDownTableView.backgroundColor = UIColor.whiteColor()
            dropDownTableView.layer.borderColor = UIColor.lightGrayColor().CGColor
            dropDownTableView.layer.borderWidth = 1.0
            dropDownTableView.showsVerticalScrollIndicator = false
            dropDownTableView.delegate = self
            dropDownTableView.dataSource = self
            dropDownTableView.estimatedRowHeight = rowHeight
            
            superview!.addSubview(dropDownTableView)
            superview!.bringSubviewToFront(dropDownTableView)
            
            dropDownTableView.translatesAutoresizingMaskIntoConstraints = false
            
            let leftConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let rightConstraint =  NSLayoutConstraint(item: dropDownTableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            heightConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: dropDownTableViewHeight)
            let topConstraint = NSLayoutConstraint(item: dropDownTableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 1)
            
            NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, heightConstraint, topConstraint])
            
//            let tapGesture = UITapGestureRecognizer(target: self, action: "tapped:")
//            tapGesture.numberOfTapsRequired = 1
//            tapGesture.cancelsTouchesInView = false
//            superview!.addGestureRecognizer(tapGesture)
        }
    }
    
//    private func tableViewAppearanceChange(appear: Bool) {
//        switch animationStyle {
//        case .Basic:
//            let basicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
//            basicAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            basicAnimation.toValue = appear ? 1 : 0
//            dropDownTableView.pop_addAnimation(basicAnimation, forKey: "basic")
//        case .Slide:
//            let basicAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
//            basicAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            basicAnimation.toValue = appear ? dropDownTableViewHeight : 0
//            heightConstraint.pop_addAnimation(basicAnimation, forKey: "heightConstraint")
//        case .Expand:
//            let springAnimation = POPSpringAnimation(propertyNamed: kPOPViewSize)
//            springAnimation.springSpeed = dropDownTableViewHeight / 100
//            springAnimation.springBounciness = 10.0
//            let width = appear ? CGRectGetWidth(frame) : 0
//            let height = appear ? dropDownTableViewHeight : 0
//            springAnimation.toValue = NSValue(CGSize: CGSize(width: width, height: height))
//            dropDownTableView.pop_addAnimation(springAnimation, forKey: "expand")
//        case .Flip:
//            var identity = CATransform3DIdentity
//            identity.m34 = -1.0/1000
//            let angle = appear ? CGFloat(0) : CGFloat(M_PI_2)
//            let rotationTransform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0)
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.dropDownTableView.layer.transform = rotationTransform
//            })
//        }
//    }
    
    func editingChanged(textField: UITextField) {
        if textField.text!.characters.count > 0 {
            setUpTable()
//            self.tableViewAppearanceChange(true)
        } else {
            
        }
    }
    
}

// Mark: UITableViewDataSoruce
extension DropDownTextField: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if aryData.count > 0{
            self.dropDownTableView.hidden = false
        }else{
            self.dropDownTableView.hidden = true
        }
        
        return aryData.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "UITableViewCell")
        
        let place = aryData[indexPath.row]
        
        cell.textLabel!.text = place.attributedPrimaryText.string
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}

// Mark: UITableViewDelegate
extension DropDownTextField: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < aryData.count{
            let place = aryData[indexPath.row]
            self.dataSourceDelegate?.searchData(place.attributedPrimaryText.string)
            aryData = []
            self.dropDownTableView.reloadData()
        }
        
    }
    
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        
        return CGFloat.min
    }
    
    
    
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return CGFloat.min        
    }
    
}



