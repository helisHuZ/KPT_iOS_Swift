//
//  Kpt_ForgetPasswordViewController.swift
//  KPT_iOS_Swift
//
//  Created by jacks on 16/6/6.
//  Copyright © 2016年 yunqiao. All rights reserved.
//

import UIKit

class Kpt_ForgetPasswordViewController: UIViewController {

    @IBOutlet weak var photoTextField: UITextField!
    @IBOutlet weak var reCaptchaTextField: UITextField!
    @IBOutlet weak var reCaptchaBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let navigationBar = self.navigationController!.navigationBar
        navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
//        navigationBar.setBackgroundImage(UIImage(named: "whiteNav"), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        
        navigationBar.barTintColor = UIColor.blackColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "忘记密码"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.systemFontOfSize(19.0),NSForegroundColorAttributeName:MainColor]
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popView")
        
         UINavigationBar.appearance().tintColor = MainColor
        
        reCaptchaBtn.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    func popView() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func reCaptchaBtnClick(sender: AnyObject) {
        //先判读电话号码无误
        let bl = photoTextField.text?.isPhotoNumber()
        print("\(bl!) 正规电话号码")
        //调用后台验证码接口，获取验证码，比对用户输入的验证码
        let paramet: [String:AnyObject] = ["requestcode":"001003","mobile":self.photoTextField.text!]
        KptRequestClient.sharedInstance.POST("/plugins/changhui/port/getVcode", parameters: paramet, progress: nil, success: { (task:NSURLSessionDataTask!, JSON) -> Void in
            let responsecode = JSON?.objectForKey("responseCode") as? String
            if (responsecode! == "1") {
                
            }else {
                let alertV = UIAlertController(title: "温馨提醒", message: JSON!.objectForKey("errorMessage") as? String, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil)
                alertV.addAction(action)
                self.presentViewController(alertV, animated: true, completion: nil)
            }
            }) { (_, error) -> Void in
                let alertV = UIAlertController(title: "温馨提醒", message: "链接不到服务器,请确定网络正常之后重试", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil)
                alertV.addAction(action)
                self.presentViewController(alertV, animated: true, completion: nil)
        }
        
        //开始倒计时
        //1.设定计时时长
        var timeout:Int = 60//结束时间
        //2.开启子线程
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        //3.创建计时器
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        //4.设置计时器时长(1秒 1 * NSEC_PER_SEC）
        dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), 1 * NSEC_PER_SEC, 0)
        weak var weakSelf = self//解决闭包循环引用 方法一
        //5.设置计时器的执行方法的内容
        dispatch_source_set_event_handler(timer) {/*[weak self]解决闭包循环引用 方法二*/ () -> Void in
            if timeout == 0 {
                dispatch_source_cancel(timer)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    weakSelf?.reCaptchaBtn.setTitle("重新获取", forState: UIControlState.Normal)
                    weakSelf?.reCaptchaBtn.userInteractionEnabled = true
                })
            }else {
                let seconds = timeout
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    weakSelf?.reCaptchaBtn.setTitle("\(seconds) 秒", forState: UIControlState.Normal)
                    weakSelf?.reCaptchaBtn.userInteractionEnabled = false
                })
            }
            timeout--
        }
        //6.启动计时器
        dispatch_resume(timer);
        
    }

    @IBAction func ensureBtnclick(sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}