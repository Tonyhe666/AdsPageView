//
//  AdPageView.swift
//  refreshDemo
//
//  Created by heliang on 16/1/16.
//  Copyright © 2016年 heliang. All rights reserved.
//

import UIKit

public protocol AdPageViewDelegate {
    // 点击广告的回调
    func tabAdPageView(AdIndex index:Int) -> Void
    
    // 加载网络图片自动回调
    func setWebImage(imgView: UIImageView, imgUrl: String) -> Void
}

class AdPageView : UIView, UIScrollViewDelegate{
    
    // MARK: - 属性
    internal var displayTime: Int = 0
    internal var bWebImage: Bool = false
    internal var delegate: AdPageViewDelegate?
    override var contentMode: UIViewContentMode {
        didSet {
            super.contentMode = contentMode
            let imgViews = [imgPre, imgCur, imgNext]
            for imgView in imgViews {
                imgView?.contentMode = contentMode
            }
        }
    }
    internal var pCCurpageTint: UIColor? {
        didSet {
            self.pageControl?.currentPageIndicatorTintColor = pCCurpageTint
        }
    }
    internal var pCPageTint: UIColor? {
        didSet{
            self.pageControl?.pageIndicatorTintColor = pCPageTint
        }
    }
    
    
    private var indexShow:Int = 0
    private var arrImageName: [String]?
    private var scView: UIScrollView?
    private var imgPre: UIImageView?
    private var imgCur: UIImageView?
    private var imgNext: UIImageView?
    private var timer: NSTimer?
    private var pageControl: UIPageControl?
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        // 备注，所有子控件的位置都是，相对于父控件来说的
        self.addSubview(UIView()) // 在有导航栏的时候，UIScrollView 的子视图会有64间距，此处采用方法2 ref： http://www.myexception.cn/mobile/2001070.html
        // 解决UIScrollView间距问题
        // 1、把scrollview的所有子视图上移64个像素。
        // 2、把scrollView更改地位，是它不是子视图树的根部第一个子视图。即在添加scrollview到父视图之前，先添加其他控件
       
        
        // 创建UIScrollView
        self.scView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(self.scView!)
        scView?.backgroundColor = UIColor.blackColor()
        self.scView?.delegate = self
        
        self.scView?.pagingEnabled = true
        self.scView?.bounces = false
        self.scView?.contentSize = CGSize(width: self.frame.width*3, height: self.frame.height) // pre -- cur -- next
        self.scView?.showsHorizontalScrollIndicator = false
        self.scView?.showsVerticalScrollIndicator = false
        self.scView?.translatesAutoresizingMaskIntoConstraints = true
        
        // 添加点击手势
        let tab: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tabAd")
        self.scView?.addGestureRecognizer(tab)
        
        // 添加图片子视图
        self.imgPre = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.imgCur = UIImageView(frame: CGRect(x: self.frame.size.width, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.imgNext = UIImageView(frame: CGRect(x: self.frame.size.width * 2, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.scView?.addSubview(imgPre!)
        self.scView?.addSubview(imgCur!)
        self.scView?.addSubview(imgNext!)

        // 添加pagecontrol
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: self.frame.size.height - 10, width: self.frame.size.width, height: 10))
        //self.pageControl?.currentPageIndicatorTintColor = UIColor.redColor()
        //self.pageControl?.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.pageControl!)

        
    }
    
    func tabAd() {
        self.timer?.invalidate()
        self.delegate?.tabAdPageView(AdIndex: (self.pageControl?.currentPage)!)
        self.startTimer()
    }
    
    func reloadImage(){
        if self.indexShow >= self.arrImageName?.count  {
            self.indexShow = 0
        }
        if self.indexShow < 0 {
            self.indexShow = (arrImageName?.count)! - 1
        }
        var pre = self.indexShow - 1
        if pre < 0 {
            pre = (self.arrImageName?.count)! - 1
        }
        var next = self.indexShow + 1
        if next > (self.arrImageName?.count)! - 1 {
            next = 0
        }
        self.pageControl?.currentPage = self.indexShow
        let preImg = arrImageName?[pre]
        let curImg = arrImageName?[self.indexShow]
        let nextImg = arrImageName?[next]
        if bWebImage {
            self.delegate?.setWebImage(self.imgPre!, imgUrl:preImg! )
            self.delegate?.setWebImage(self.imgCur!, imgUrl:curImg! )
            self.delegate?.setWebImage(self.imgNext!, imgUrl:nextImg! )
        }
        else {
            self.imgPre?.image = UIImage(named: preImg!)
            self.imgCur?.image = UIImage(named: curImg!)
            self.imgNext?.image = UIImage(named: nextImg!)
        }
        
        self.scView?.scrollRectToVisible(CGRect(x: self.frame.size.width, y: 0, width: self.frame.size.width, height: self.frame.size.height), animated: false)
        self.startTimer()
    }
    
    func startTimer() {
        if self.displayTime > 0 {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.displayTime), target: self, selector: "changeImages", userInfo: nil, repeats: false)
        }
    }
    
    func changeImages() {
        self.scView?.scrollRectToVisible(CGRect(x: self.frame.size.width * 2, y: 0, width: self.frame.size.width, height: self.frame.size.height), animated: true)
        self.indexShow++
        self.performSelector("reloadImage", withObject: nil, afterDelay: 0.3)
    }
    
    
    // MARK: - scrollView delegate  手动拖拽停止时候执行
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.timer?.invalidate()
        if scrollView.contentOffset.x >= self.frame.size.width * 2 {
            self.indexShow++
        }
        else if scrollView.contentOffset.x < self.frame.size.width {
            self.indexShow--
        }
        self.reloadImage()
        
    }
    
    
    // MARK: - start ad
    
    func startAds(name arrImage: [String]) {
        if arrImage.count <= 1 {
            self.scView?.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
            self.pageControl?.hidden = true
        }
        else {
            self.pageControl?.hidden = false
        }
        
        self.pageControl?.numberOfPages = arrImage.count
        self.arrImageName = arrImage
        self.reloadImage()
    }
    
    // MARK: - end ad
    func stopAds() {
        self.timer?.invalidate()
    }
}