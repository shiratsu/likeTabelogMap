//
//  MapViewModel.swift
//  mapSample
//
//  Created by 平塚 俊輔 on 2016/03/14.
//  Copyright © 2016年 平塚 俊輔. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class MapViewModel:NSObject {
    
    let api:SampleApi = SampleApi()
    
    var items: Variable<NSArray> = Variable(NSArray())
    let disposeBag = DisposeBag()
    
    func searchLocation(param:NSDictionary){
        api.getAddressInfo(param)
            .catchError{ error -> Observable<NSArray> in
                print("取得できませんでした")
                return Observable.just(NSArray())
            }
            .subscribeNext { [weak self] array in
                
                self?.items.value = array
            }
            .addDisposableTo(disposeBag)
    }
    
    
    
}