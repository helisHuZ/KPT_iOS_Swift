//
//  Kpt_RegisterViewController.swift
//  KPT_iOS_Swift
//
//  Created by jacks on 16/5/25.
//  Copyright © 2016年 yunqiao. All rights reserved.
//

import UIKit
import AFNetworking

class Kpt_RegisterViewController: UIViewController {

    @IBOutlet weak var photoTextField: UITextField!
    @IBOutlet weak var reCaptchaButton: UIButton!
    @IBOutlet weak var reCaptchaTextField: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var perfectView: UIView!
    private var backView:UIView!
    @IBOutlet weak var perfectBtn: UIButton!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        reCaptchaButton.layer.cornerRadius = 5
        perfectBtn.backgroundColor = MainColor
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
                print(error)
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
                    weakSelf?.reCaptchaButton.setTitle("重新获取", forState: UIControlState.Normal)
                    weakSelf?.reCaptchaButton.userInteractionEnabled = true
                })
            }else {
                let seconds = timeout
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    weakSelf?.reCaptchaButton.setTitle("\(seconds) 秒", forState: UIControlState.Normal)
                    weakSelf?.reCaptchaButton.userInteractionEnabled = false
                })
            }
            timeout--
        }
        //6.启动计时器
        dispatch_resume(timer);
        
    }
    @IBAction func registerButtonClick(sender: AnyObject) {
        //判断所填写的信息无误
        backView = UIView(frame: UIScreen.mainScreen().bounds)
        backView.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 0.8)
        backView.addSubview(self.perfectView)
        self.perfectView.hidden = false
        self.perfectView.center = CGPoint(x: SCRW * 0.5, y: SCRH * 1.5)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            UIApplication.sharedApplication().keyWindow!.addSubview(self.backView)
            self.perfectView.center = CGPoint(x: SCRW * 0.5, y: SCRH * 0.5)
        })

        let paramet: [String:AnyObject] = ["requestcode":"001001","mobile":self.photoTextField.text!,"vcode":self.reCaptchaTextField.text!,"password":self.passwordText.text!]
            
            KptRequestClient.sharedInstance.Kpt_post("/plugins/changhui/port/register", paramet: paramet, viewController: self) { (data) -> Void in
                print(data)
                //弹出提示框，是否完善个人信息
                //跳转到指定界面
        }

    }
    
    @IBAction func falsePerfectBtnClick(sender: AnyObject) {
        self.backView.removeFromSuperview()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
 
    //完善个人信息
    @IBAction func perfectBtnClick(sender: AnyObject) {
        self.backView.removeFromSuperview()
        navigationController?.pushViewController(UserInfoViewController(), animated: true)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        FoldUpTheKeyboard()
    }
    //将键盘收起
    private func FoldUpTheKeyboard() {
        self.photoTextField.resignFirstResponder()
        self.reCaptchaTextField.resignFirstResponder()
        self.passwordText.resignFirstResponder()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        FoldUpTheKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
