//
//  DropDownTextField.swift
//  mapSample
//
//  Created by 平塚 俊輔 on 2016/03/30.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import UIKit

// MARK: Dropdown Delegate
public protocol DropDownTextFieldDataSourceDelegate: NSObjectProtocol {

    func getheaderHeight() -> CGFloat
    func getRowCount() -> Int
    func dropDownTextField(dropDownTextField: DropDownTextField, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    func dropDownTextField(dropDownTextField: DropDownTextField, didSelectRowAtIndexPath indexPath: NSIndexPath)
    
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
            

        }
    }
    

    
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
        if self.dataSourceDelegate != nil{
            return self.dataSourceDelegate!.getRowCount()
        }
        return 0
        
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.dataSourceDelegate != nil {
            return dataSourceDelegate!.dropDownTextField(self, cellForRowAtIndexPath: indexPath)
        }
        return UITableViewCell()
    }
}

// Mark: UITableViewDelegate
extension DropDownTextField: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.dataSourceDelegate != nil {
            self.dataSourceDelegate!.dropDownTextField(self, didSelectRowAtIndexPath: indexPath)
        }
        
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if self.dataSourceDelegate != nil{
            return self.dataSourceDelegate!.getheaderHeight()
        }
        return CGFloat.min
    }
}



