//
//  ViewController.swift
//  SKPercentWaterView
//
//  Created by nachuan on 2017/1/23.
//  Copyright © 2017年 nachuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var _percentView: SKPercentWaterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let percentView = SKPercentWaterView();
        percentView.frame = CGRect(x: 100, y: 100, width: 200, height: 200);
        percentView.lineWidth = 4;
        percentView.topLineWidth = 4;
        self.view.addSubview(percentView);
        _percentView = percentView;
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _percentView.setupProgress(CGFloat(arc4random()%100)/100);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}











































