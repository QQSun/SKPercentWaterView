//
//  SKPercentWaterView.swift
//  SKPercentWaterView
//
//  Created by nachuan on 2017/1/23.
//  Copyright © 2017年 nachuan. All rights reserved.
//

import UIKit

public var animationDuration: TimeInterval = 1.0;

class SKPercentWaterView: UIView {

    //MARK: - 私有存储属性
    private var _topLayer: CAShapeLayer!
    private var _bottomLayer: CAShapeLayer!
    private var _circlePath: UIBezierPath!
    private var _waterTimer: Timer!
    private var _percent: CGFloat = 0.0;
    private var _horizontal: CGFloat = 0.0;
    private var _waterView: UIView!;
    private var _bottomLabel: UILabel!
    private var _topLabel: UILabel!
    private var _originY: CGFloat = 0;
    //MARK: - 公共存储属性
    
    var topLineWidth: CGFloat = 0.0;
    var topLineColor: UIColor = .blue;
    var lineWidth: CGFloat = 0.0;
    var lineColor: UIColor = .lightGray;
    var waterColor: UIColor = .green;
    
    
    
    
    public func setupProgress(_ progress: CGFloat) -> Void {
        if progress >= 0 || progress <= 1 {
            _topLayer.strokeEnd = 1;
        }
        _topLabel.text = "\(Int(progress * 100))%";
        _bottomLabel.text = "\(Int(progress * 100))%";
        print(progress);
        _originY = progress * self.frame.height;
//        UIView.animate(withDuration: 0.1) {
//            
//            self._waterView.layer.frame = CGRect(x: 0, y: self.frame.height * (1 - progress) - 20, width: self.frame.width, height: self.frame.height + 20);
//        };
        setNeedsDisplay();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        configureView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        configureView();
    }
    
    func configureView() -> Void {
        self.backgroundColor = .clear;
        createWaterView();
        createLabel();
        setDisplayLink();
    }
    
    func setDisplayLink() -> Void {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation));
        displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode);
    }
    
    @objc func updateAnimation() -> Void {
        let wavePath: CGMutablePath = CGMutablePath();
        wavePath.move(to: CGPoint(x: 0, y: -self.frame.height * 0.5));
        var tempY: CGFloat = 0;
        _horizontal += 0.2;
        for x: Int in 0...Int(self.frame.width) {
            tempY = 5 * sin(CGFloat(x) * CGFloat(M_PI) / self.frame.width * 5.5 + _horizontal);
            wavePath.addLine(to: CGPoint(x: CGFloat(x), y: tempY + _originY));
        }
        wavePath.addLine(to: CGPoint(x: self.frame.width, y: -self.frame.height * 0.5));
        wavePath.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height + 20));
        wavePath.addLine(to: CGPoint(x: 0, y: self.frame.width + 20));
        setupMask(for: _waterView, with: wavePath);
        _topLabel.layer.mask = _waterView.layer.mask;

    }
    
    func setupMask(for view: UIView, with path: CGPath?) -> Void {
        if path == nil {
            view.layer.mask = nil;
        }else{
            let maksLayer = CAShapeLayer();
            maksLayer.path = path;
            view.layer.mask = maksLayer;
        }
        
    }
    
    func createWaterView() -> Void {
        let waterView = UIView();
        waterView.backgroundColor = waterColor;
        waterView.layer.masksToBounds = true;
        self.addSubview(waterView);
        _waterView = waterView;
    }

    func createLabel() -> Void {
        let bottomLabel = UILabel();
        bottomLabel.backgroundColor = .cyan;
        bottomLabel.font = UIFont.systemFont(ofSize: 72);
        bottomLabel.textColor = .red;
        bottomLabel.textAlignment = .center;
        self.addSubview(bottomLabel);
        _bottomLabel = bottomLabel;
        
        let topLabel = UILabel();
        topLabel.backgroundColor = .blue;
        topLabel.font = UIFont.systemFont(ofSize: 72);
        topLabel.textColor = .purple;
        topLabel.textAlignment = .center;
        self.addSubview(topLabel);
        _topLabel = topLabel;
    }

    func startAnimation(with value: CGFloat) -> Void {
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd");
        pathAnimation.duration = animationDuration;
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        pathAnimation.fromValue = NSNumber(value: 0.0);
        pathAnimation.toValue = NSNumber(value: Float(value));
        pathAnimation.fillMode = kCAFillModeForwards;
        pathAnimation.isRemovedOnCompletion = false;
        _topLayer.add(pathAnimation, forKey: "pathAnimation");
    }
    
    override func draw(_ rect: CGRect) {
        if _circlePath == nil {
            let pCenter: CGPoint = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5);
            var radius = min(rect.width, rect.height);
            radius -= topLineWidth;
            let circlePath = UIBezierPath();
            circlePath.addArc(withCenter: pCenter, radius: radius * 0.5, startAngle: 270.0 * CGFloat(M_PI) / 180.0, endAngle: 269.0 / 180.0 * CGFloat(M_PI), clockwise: true);
            circlePath.close();
            _circlePath = circlePath;
        }
        
        if _bottomLayer == nil {
            let bottomLayer = CAShapeLayer();
            bottomLayer.frame = rect;
            bottomLayer.path = _circlePath.cgPath;
            bottomLayer.fillColor = UIColor.clear.cgColor;
            bottomLayer.lineWidth = lineWidth;
            bottomLayer.strokeColor = lineColor.cgColor;
            bottomLayer.lineCap = kCALineCapRound;
            self.layer.addSublayer(bottomLayer);
            _bottomLayer = bottomLayer;
        }
        
        if _topLayer == nil {
            let topLayer = CAShapeLayer();
            topLayer.frame = rect;
            topLayer.path = _circlePath.cgPath;
            topLayer.fillColor = UIColor.clear.cgColor;
            topLayer.lineWidth = lineWidth;
            topLayer.strokeColor = topLineColor.cgColor;
            topLayer.strokeEnd = 0.5;
            topLayer.lineCap = kCALineCapRound;
            self.layer.addSublayer(topLayer);
            _topLayer = topLayer;
        }
        if _waterView.frame == CGRect.zero {
            _waterView.frame = self.bounds;
        }
        _topLabel.frame = self.bounds;
        setupMask(for: self, with: _circlePath.cgPath);
        self.startAnimation(with: _percent);
    }
    
}















































