//
//  ViewController.swift
//  SolarSystem
//
//  Created by gjh on 2017/11/19.
//  Copyright © 2017年 Gjianhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickBtn(_ sender: Any) {
        // 页面跳转
        let sceneViewVC = SceneViewViewController()
        self.present(sceneViewVC, animated: true, completion: nil)
        // 返回
        // self.dismiss(animated: true, completion: nil)
        
        // 导航 push 跳转
        // self.navigationController?.pushViewController(sceneViewVC, animated: true)
        // 返回
        // self.navigationController?.popViewController(animated: true)
    }
    
}

