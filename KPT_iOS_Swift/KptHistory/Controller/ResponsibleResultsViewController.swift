//
//  ResponsibleResultsViewController.swift
//  KPT_iOS_Swift
//
//  Created by jacks on 16/6/27.
//  Copyright © 2016年 yunqiao. All rights reserved.
//

import UIKit


class ResponsibleResultsViewController: UIViewController {

    ///我方车牌号码
    @IBOutlet weak var myCarLabel: UILabel!
    ///对方车牌号码
    @IBOutlet weak var otherCarnoLabel: UILabel!
    ///我方承担责任示意图
    @IBOutlet weak var progressView: UIView!
    ///我方承担责任说明Label
    @IBOutlet weak var ourResponsibilityLabel: UILabel!
    ///对方承担责任示意图
    @IBOutlet weak var otherProgressView: UIView!
    ///对方承担责任说明Label
    @IBOutlet weak var otherResponsibilityLabel: UILabel!
    
    @IBOutlet weak var mainSlider: UISlider!
    ///用于接收车辆信息(选择责任分担之后)
    var partiesdataArr : NSMutableArray!
    ///用于接收选择的责任类型(主责...)
    var responsibilityStr:String!
    
    ///当事人信息(主要包含任务id和当事人id)
    var responsibilitydata:NSDictionary!
    ///事故场景
    var accidentType : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "定责结果"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "展开"), style: UIBarButtonItemStyle.Plain, target: self, action: "disSelfView")
        self.navigationItem.leftBarButtonItem?.tintColor = MainColor
        
        
        self.progressView.addSubview(self.progressBackView)
        self.otherProgressView.addSubview(self.otherProgressBackView)
        
        print(self.partiesdataArr)
        //设置比例图和比例说明
        setLabelAndResponsibility()
        
        otherProgressBackView.percent = 1.0 - progressBackView.percent
        self.mainSlider.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI * 0.5))
        
        self.mainSlider.value = self.progressBackView.percent
        //设置车辆车牌号码
        setCarNo()
    }
    func disSelfView() {
        let alertC = UIAlertController(title: nil, message: "是否退出此任务？\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "继续", style: UIAlertActionStyle.Default) { (action) -> Void in
            alertC.dismissViewControllerAnimated(true, completion: nil)
        }
        cancelAction .setValue(MainColor, forKey: "titleTextColor")
        alertC.addAction(cancelAction)
        
        let action = UIAlertAction(title: "退出", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        action.setValue(UIColor.grayColor(), forKey: "titleTextColor")
        alertC.addAction(action)
        
        self.presentViewController(alertC, animated: true, completion: nil)
    }
    
    private func setCarNo() {
        for dict in partiesdataArr {
            if ((dict as? NSDictionary) != nil)  {
                if dict.objectForKey("partiesmark")?.integerValue == 0 {
                  self.myCarLabel.text = dict.objectForKey("partiescarno") as? String
                }else if dict.objectForKey("partiesmark")?.integerValue == 1{
                    self.otherCarnoLabel.text = dict.objectForKey("partiescarno") as? String
                }
            }
        }
    }
    
    //有争议按钮点击事件
    @IBAction func controversialBtnClick(sender: AnyObject) {
        let alertC = UIAlertController(title: nil, message: "双方存在争议，是否提交由交警在线定责？", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelA =  UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertC.addAction(cancelA)
        let alertA = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (alertA) -> Void in
            print("提交交警")
            let userDefault = NSUserDefaults.standardUserDefaults()
            let personalData = userDefault.objectForKey("userInfoLoginData") as! NSDictionary
            let userInfoData = UserInfoData.mj_objectWithKeyValues(personalData)
            
            let arr = self.responsibilitydata.objectForKey("responsibilitydata") as! NSMutableArray
            let dataDict = NSMutableDictionary()
            let dataArr = NSMutableArray()
            for dict in arr {
                if let _ = dict as? NSMutableDictionary {
                    dataDict.setValue("责任不明确", forKey: "dutyname")
                    dataDict.setValue(dict.objectForKey("partiesid")!, forKey: "partiesid")
                    dataDict.setValue(dict.objectForKey("partiesmark")!, forKey: "partiesmark")
                    dataArr.addObject(dataDict)
                }
                
            }
            print(dataArr)
            
            let data : NSDictionary = ["taskid":self.responsibilitydata.objectForKey("taskid")!,"flowcode":"200102","flowname":"责任认定","accidentscene":self.accidentType,"fixduty":"2","isconfirm":"0","responsibilitydata":dataArr]
            let parame = ["requestcode":"003002","accessid":userInfoData.accessid,"accesskey":userInfoData.accesskey,"userid":userInfoData.userid,"data":data]
            
            KptRequestClient.sharedInstance.Kpt_post("/plugins/changhui/port/task/dutytask", paramet: parame, viewController: self, success: { (data) -> Void in
                print(data)
                }, failure: { (_) -> Void in
                    
            })
        })
        alertA.setValue(MainColor, forKey: "titleTextColor")
        alertC.addAction(alertA)
        self.presentViewController(alertC, animated: true, completion: nil)
    }

    //无争议按钮点击事件
    @IBAction func nodisputeBtnClick(sender: AnyObject) {
        let alertC = UIAlertController(title: nil, message: "是否提交责任比例，提交后无法再次修改！", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelA =  UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertC.addAction(cancelA)
        let alertA = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (alertA) -> Void in
                self.uploadDutyRatio()
        })
        alertA.setValue(MainColor, forKey: "titleTextColor")
        alertC.addAction(alertA)
        self.presentViewController(alertC, animated: true, completion: nil)
    }
    func uploadDutyRatio() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let personalData = userDefault.objectForKey("userInfoLoginData") as! NSDictionary
        let userInfoData = UserInfoData.mj_objectWithKeyValues(personalData)
        
        let arr = self.responsibilitydata.objectForKey("responsibilitydata") as! NSMutableArray
        let dataDict = NSMutableDictionary()
        let dataArr = NSMutableArray()
        for dict in arr {
            if let _ = dict as? NSMutableDictionary {
                if dict.objectForKey("partiesmark")!.integerValue == 0 {
                    dataDict.setValue(self.responsibilityStr, forKey: "dutyname")
                    dataDict.setValue(dict.objectForKey("partiesid")!, forKey: "partiesid")
                    dataDict.setValue(self.progressBackView.percent, forKey: "dutyratio")
                    dataDict.setValue(dict.objectForKey("partiesmark")!, forKey: "partiesmark")
                    
                }else {
                    var dutyname = ""
                    if self.responsibilityStr == "主责" {
                        dutyname = "次责"
                    }else if self.responsibilityStr == "全责" {
                        dutyname = "无责"
                    }else if self.responsibilityStr == "次责" {
                        dutyname = "主责"
                    }else if self.responsibilityStr == "共同责任" {
                        dutyname = "共同责任"
                    }else {
                        dutyname = "全责"
                    }
                    dataDict.setValue(dutyname, forKey: "dutyname")
                    dataDict.setValue(dict.objectForKey("partiesid")!, forKey: "partiesid")
                    dataDict.setValue(self.otherProgressBackView.percent, forKey: "dutyratio")
                    dataDict.setValue(dict.objectForKey("partiesmark")!, forKey: "partiesmark")
                }
                dataArr.addObject(dataDict)
            }
            
        }
        print(dataArr)
        
        let data : NSDictionary = ["taskid":self.responsibilitydata.objectForKey("taskid")!,"flowcode":"200102","flowname":"责任认定","accidentscene":self.accidentType,"fixduty":"1","isconfirm":"1","responsibilitydata":dataArr]
        let parame = ["requestcode":"003002","accessid":userInfoData.accessid,"accesskey":userInfoData.accesskey,"userid":userInfoData.userid,"data":data]
        
        KptRequestClient.sharedInstance.Kpt_post("/plugins/changhui/port/task/dutytask", paramet: parame, viewController: self, success: { (data) -> Void in
            print(data)
            
            let flowid = (data as! NSDictionary).objectForKey("flowid")
            let responsibleVC = AutographViewController(nibName:"AutographViewController",bundle: nil)
            responsibleVC.responsibilitydata = self.responsibilitydata
            responsibleVC.partiesdataArr = self.partiesdataArr
            responsibleVC.flowid = flowid as! String
            responsibleVC.myPercentage = self.progressBackView.percent
            
            self.navigationController?.pushViewController(responsibleVC, animated: true)
            
            }, failure: { (_) -> Void in
                
        })
    }
    //
    @IBAction func mainSliderClick(sender: AnyObject) {
        let sendfloat = Int(self.mainSlider.value * 100)
        
        self.progressBackView.percent = Float(sendfloat) / 100
        
        self.otherProgressBackView.percent = 1 - self.progressBackView.percent
        responsibilitySharing()
    }
    @IBAction func plusBtnClick(sender: AnyObject) {
        if self.progressBackView.percent == 1 || self.progressBackView.percent == 0 {
            return
        }
        self.progressBackView.percent += 0.01
        
        self.otherProgressBackView.percent = 1 - self.progressBackView.percent
        responsibilitySharing()
    }
    @IBAction func minusBtnClick(sender: AnyObject) {
        if self.progressBackView.percent == 1 || self.progressBackView.percent == 0 {
            return
        }
        self.progressBackView.percent -= 0.01
        self.otherProgressBackView.percent = 1 - self.progressBackView.percent
        responsibilitySharing()
    }
    private func responsibilitySharing() {
        if self.progressBackView.percent > 1 || self.progressBackView.percent < 0 {
            return
        }
        if self.progressBackView.percent > 0.5 && self.progressBackView.percent < 1{
            self.ourResponsibilityLabel.text = "我方主责  我方承担\(self.progressBackView.percent*100)%责任"
            self.otherResponsibilityLabel.text = "对方次责  对方承担\(100 - self.progressBackView.percent*100)%责任"
        }else if self.progressBackView.percent  == 1{
            self.ourResponsibilityLabel.text = "我方全责  我方承担100%责任"
            self.otherResponsibilityLabel.text = "对方无责  对方承担0%责任"
        }else if self.progressBackView.percent  == 0.5{
            self.ourResponsibilityLabel.text = "我方共同责任  我方承担50%责任"
            self.otherResponsibilityLabel.text = "对方共同责任  对方承担50%责任"
        }else if self.progressBackView.percent  < 0.5 && self.progressBackView.percent > 0{
            self.ourResponsibilityLabel.text = "我方次责  我方承担\(self.progressBackView.percent*100)%责任"
            self.otherResponsibilityLabel.text = "对方主责  对方承担\(100 - self.progressBackView.percent*100)%责任"
        }else if self.progressBackView.percent  == 0{
            self.ourResponsibilityLabel.text = "我方无责  我方承担0%责任"
            self.otherResponsibilityLabel.text = "对方全责  对方承担100%责任"
        }
    }
    private func setLabelAndResponsibility() {
        if responsibilityStr == "全责" {
            self.progressBackView.percent = 1
            
        }else if responsibilityStr == "主责" {
            self.progressBackView.percent = 0.7
            
        }else if responsibilityStr == "次责" {
            self.progressBackView.percent = 0.3
            
        }else if responsibilityStr == "共同责任" {
            self.progressBackView.percent = 0.5
            
        }else if responsibilityStr == "无责" {
            self.progressBackView.percent = 0
        }
        responsibilitySharing()
        
    }
    
    private lazy var progressBackView : Kpt_ProgressView = {
        
        let view = Kpt_ProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        view.arcBackColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
        view.arcFinishColor = MainColor
        view.arcUnfinishColor = MainColor
        
        return view
    }()
    
    private lazy var otherProgressBackView : Kpt_ProgressView = {
        let view = Kpt_ProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        view.arcBackColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)
        view.arcFinishColor = MainColor
        view.arcUnfinishColor = MainColor
        
        return view
    }()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}