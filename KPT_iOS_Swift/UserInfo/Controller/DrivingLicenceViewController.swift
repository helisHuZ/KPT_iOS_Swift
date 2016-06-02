//
//  DrivingLicenceViewController.swift
//  KPT_iOS_Swift
//
//  Created by jacks on 16/5/27.
//  Copyright © 2016年 yunqiao. All rights reserved.
//

import UIKit

class DrivingLicenceViewController: UIViewController,Kpt_NextBtnViewDelegate {

    var imageView:Kpt_OCRImageView?
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        view = tableView
        // Do any additional setup after loading the view.
    }
    func nextBtnClick(nextBtn: Kpt_NextBtnView) {
        self.navigationController?.pushViewController(CarInfoViewController(), animated: true)
    }
    private lazy var tableView:UITableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
    private lazy var oneArr = ["姓名","身份证号","性别","国籍","住址"]
    private lazy var twoArr = ["出生日期","初次领证日期","准驾车型","有效起始日期","有效期限"]
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension DrivingLicenceViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return oneArr.count
        }
        return twoArr.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let DrivingCell = "DrivingCellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(DrivingCell)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: DrivingCell)
        }
        if indexPath.section == 0 {
            cell?.textLabel?.text = oneArr[indexPath.row]
        } else {
            cell?.textLabel?.text = twoArr[indexPath.row]
        }
        return cell!
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01//设置为0，不会有效果，会变成默认高度
        }else {
            return 100
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 210
        }
        else {
            return 20
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.RGBA(218, g: 218, b: 218)
        if section == 0 {
            view.frame = CGRect(x: 0, y:0, width: SCRW, height: 200)
            imageView = Kpt_OCRImageView.creatTouchImage(CGRect(x: 0, y: 0, width: SCRW, height: 180),documentType:"驾驶证",controller:self)
            imageView?.backgroundColor = UIColor.whiteColor()
            view.addSubview(imageView!)
            let label = UILabel(frame: CGRect(x: 15, y: view.frame.size.height - 15, width: 100, height: 20))
            label.text = "驾驶证信息"
            view.addSubview(label)
            
        }else {
            view.frame = CGRect(x: 0, y: 0, width: SCRW, height: 20)
        }
        return view
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: SCRW, height: 100))
        backView.backgroundColor = UIColor.RGBA(218, g: 218, b: 218)
        let view = Kpt_NextBtnView(frame: CGRect(x: 0, y: 20, width: SCRW, height: 80))
        view.delegate = self
        view.backgroundColor = UIColor.whiteColor()
        backView.addSubview(view)
        return backView
    }
}