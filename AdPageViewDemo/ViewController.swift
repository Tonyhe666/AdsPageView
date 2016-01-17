//
//  ViewController.swift
//  AdPageViewDemo
//
//  Created by heliang on 16/1/17.
//  Copyright © 2016年 heliang. All rights reserved.
//

import UIKit

class ViewController: UIViewController , AdPageViewDelegate{
    
    var adPageView: AdPageView?
    
    deinit {
        adPageView?.stopAds()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let localImages = ["1", "2", "3"]
        let webImages = ["http://img0.bdstatic.com/img/image/2016ss1.jpg","http://img0.bdstatic.com/img/image/dac851da0acb309ff997dfba8184d4781418016764.jpg","http://img0.bdstatic.com/img/image/1165fa709c98224247f6f9f81b45a4ab1409118681.jpg"]
        
        self.adPageView = AdPageView(frame: CGRect(x: 0, y: 20, width: UIScreen.mainScreen().bounds.size.width, height: 300))
        if let adView = adPageView {
            adView.pCCurpageTint = UIColor.blueColor()
            adView.pCPageTint = UIColor.redColor()
            adView.displayTime = 3
            adView.delegate = self
            adView.contentMode = .ScaleToFill
            adView.bWebImage = true
            if adView.bWebImage {
                // 加载网络图片
                 adView.startAds(name: webImages)
            }
            else {
                // 加载本地图片
                 adView.startAds(name: localImages)
            }
           self.view.addSubview(adView)
        }
    }
    
    // 点击广告的回调
    func tabAdPageView(AdIndex index:Int) -> Void {
        print("点击了\(index)个广告")
    }
    
    // 加载网络图片自动回调
    func setWebImage(imgView: UIImageView, imgUrl: String) -> Void {
        imgView.sd_setImageWithURL(NSURL(string: imgUrl), placeholderImage: UIImage(named: "1"))
    }
    
}

