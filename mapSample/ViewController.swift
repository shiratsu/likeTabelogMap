//
//  ViewController.swift
//  mapSample
//
//  Created by 平塚 俊輔 on 2016/03/10.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import UIKit
import GoogleMaps
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class ViewController: UIViewController,UITextFieldDelegate,InfoCardDelegate,UIScrollViewDelegate,GMSMapViewDelegate {

    var searchText: UITextField!
    var scrollView: UIScrollView!
    var mapView:GMSMapView!
    
    let viewModel:MapViewModel = MapViewModel()
    let disposeBag = DisposeBag()
    
    /**
     xibを読み込む
     */
    override func loadView() {
        if let view = UINib(nibName: "ViewController", bundle: nil).instantiateWithOwner(self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.cameraWithLatitude(35.6646308,
            longitude: 139.7394723, zoom: 16)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        mapView.delegate = self
        self.view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(35.6548503,139.7501517 )
        marker.title = "東京都"
        marker.snippet = "芝公園駅"
        marker.map = mapView
        
        searchText = UITextField(frame: CGRect(x: 10, y: 10, width: UIScreen.mainScreen().bounds.size.width-20, height: 30))
        searchText.backgroundColor = UIColor.whiteColor()
        searchText.delegate = self
        self.view.addSubview(searchText)
        
        setConstRaintText()
        
        setSubscribe()
        
        
    }
    
    func setSubscribe(){
        viewModel.items.asObservable()
            .subscribeNext { [weak self] array in
                
                print(array)
                
                if ((self?.scrollView?.isDescendantOfView((self?.view)!)) != nil){
                    self?.scrollView.removeFromSuperview()
                }
                
                
                
                self?.scrollView = UIScrollView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height-120, width: UIScreen.mainScreen().bounds.size.width, height: 120))
                self?.scrollView.pagingEnabled = true
                self?.scrollView.delegate = self
                let infoWidth:CGFloat = UIScreen.mainScreen().bounds.size.width
                var x:CGFloat = 0
                var i = 0
                
                for loc in array{
                    let locationInfo = InfoCard.instance()
                    locationInfo.backgroundColor = UIColor.clearColor()
                    locationInfo.delegate = self
                    locationInfo.setInfomation(loc as! NSDictionary)
                    
                    print(loc)
                    print(locationInfo)
                    
                    if i == 0{
                        
                        //地図を一個目の地点に移動
                        let moveToCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(locationInfo.y), CLLocationDegrees(locationInfo.x))
                        
                        let camera = GMSCameraPosition.cameraWithLatitude(moveToCoordinate.latitude, longitude: moveToCoordinate.longitude, zoom: 16)
                        self?.mapView.animateToCameraPosition(camera)
                        
                        locationInfo.frame = CGRect(x: 0, y: 0, width: infoWidth, height: 80)
                    }else{
                        locationInfo.frame = CGRect(x: x, y: 0, width: infoWidth, height: 80)
                    }
                    x += infoWidth
                    
                    let position = CLLocationCoordinate2DMake(CLLocationDegrees(locationInfo.y), CLLocationDegrees(locationInfo.x))
                    let marker = CustomGMSMarker(position: position)
                    marker.title = locationInfo.titleLabel.text
                    marker.icon = UIImage(named: "mapIcon")
                    marker.map = self?.mapView
                    marker.tag = i
                    
                    self?.scrollView.addSubview(locationInfo)
                    i++
                }
                self?.scrollView.contentSize = CGSize(width: CGFloat(x)+15, height: (self?.scrollView.frame.size.height)!)
                
                self?.view.addSubview((self?.scrollView)!)
                
            }
            .addDisposableTo(disposeBag)
    }
    
    
    
    
    /**
     constraint追加
     */
    func setConstRaintText(){
        
        //追加する
        let top_constraint = NSLayoutConstraint(
            item: searchText,
            attribute: NSLayoutAttribute.Top,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: 10)
        
        let left_constraint = NSLayoutConstraint(
            item: searchText,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 10)
        
        let right_constraint = NSLayoutConstraint(
            item: searchText,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: 10)
        
        self.view.addConstraint(top_constraint)
        self.view.addConstraint(left_constraint)
        self.view.addConstraint(right_constraint)
        
        let height_constraint = NSLayoutConstraint(
            item: searchText,
            attribute: NSLayoutAttribute.Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 30)
        
        self.searchText.addConstraint(height_constraint)
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField){
        print(textField.text)
    }
    
    func textFieldDidEndEditing(textField: UITextField){
        print(textField.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        
        let searchText = textField.text
        let dicParam:NSMutableDictionary = NSMutableDictionary()
        dicParam.setValue("suggest", forKey: "method")
        dicParam.setValue("like", forKey: "matching")
        dicParam.setValue(searchText, forKey: "keyword")
        viewModel.searchLocation(dicParam)
        
        return true
    }
    
    
    /**
     UITextFieldが反応するように
     
     - parameter mapView: <#mapView description#>
     */
    class func removeGMSBlockingGestureRecognizerFromMapView(mapView:GMSMapView){
        //print(mapView.gestureRecognizers)
        
        if mapView.settings.respondsToSelector("consumesGesturesInView"){
            mapView.settings.consumesGesturesInView = false
        }else{
            for gestureRecognizer in mapView.gestureRecognizers!{
                
                if let longGestture = gestureRecognizer as? UILongPressGestureRecognizer{
                    mapView.removeGestureRecognizer(longGestture)
                }
                
            }
        }
        
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.frame.size.width
        
        guard let dicLoc = viewModel.items.value.safeObjectAtIndex(Int(index)) as? NSDictionary else{
            return
        }
        
        let strx = dicLoc.objectForKey("x") as? String ?? "0"
        let stry = dicLoc.objectForKey("y") as? String ?? "0"
        let x = CGFloat(NSString(string: strx).floatValue)
        let y = CGFloat(NSString(string: stry).floatValue)
        //地図の中心点を移動
        move(x, y: y)
        
    }
    
    func move(x:CGFloat,y:CGFloat){
        let moveToCoordinate = CLLocationCoordinate2DMake(CLLocationDegrees(y), CLLocationDegrees(x))
        
        let camera = GMSCameraPosition.cameraWithLatitude(moveToCoordinate.latitude, longitude: moveToCoordinate.longitude, zoom: 16)
        self.mapView.animateToCameraPosition(camera)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ViewController.removeGMSBlockingGestureRecognizerFromMapView(mapView)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if let customMarker = marker as? CustomGMSMarker{
            print(mapView.selectedMarker)
            if let selectedMarker = mapView.selectedMarker as? CustomGMSMarker{
                selectedMarker.icon = UIImage(named: "mapIcon")
            }
            
            let index = customMarker.tag
            let changeOffset = CGFloat(index)*UIScreen.mainScreen().bounds.size.width
            
            var frame = scrollView.frame
            frame.origin.x = changeOffset
            frame.origin.y = 0
            customMarker.icon = UIImage(named: "changeIcon")
            mapView.selectedMarker = customMarker
            
            scrollView.scrollRectToVisible(frame, animated: true)
            
            move(CGFloat(customMarker.layer.longitude), y: CGFloat(customMarker.layer.latitude))
            
            
        }
        
        
        return true
    }
    
    
    

}



extension NSArray{
    func safeObjectAtIndex(index: Int) ->AnyObject?{
        if index >= self.count{
            return nil
        }
        return self.objectAtIndex(index)
    }
    
    
}
