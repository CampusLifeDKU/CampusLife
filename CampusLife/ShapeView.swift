//
//  ShapeView.swift
//  SimpleDrawingGesture
//
//  Created by Park on 11/1/15.
//  Copyright © 2015 Park. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    let size: CGFloat = 150.0
    let lineWidth: CGFloat = 3
    var fillColor: UIColor!
    var path: UIBezierPath!
    
    init(origin: CGPoint) {
        super.init(frame: CGRectMake(0.0, 0.0, size, size))
        self.center = origin
        self.backgroundColor = UIColor.clearColor()
        self.fillColor = randomColor()
        self.path = randomPath()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "didPan:")
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "didPinch:")
        addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: "didRotate:")
        addGestureRecognizer(rotationGesture)
    }
    
    // We need to implement init(coder) to avoid compilation errors
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        //let insetRect = CGRectInset(rect, lineWidth / 2, lineWidth / 2)
        
        //let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10)
        
        //UIColor.redColor().setFill()
        self.fillColor.setFill()
        self.path.fill()
        
        path.lineWidth = self.lineWidth
        UIColor.blackColor().setStroke()
        self.path.stroke()
    }
    
    func randomColor() -> UIColor {
        let hue:CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.8)
    }
    
    func randomPath() -> UIBezierPath {
        
        let insetRect = CGRectInset(self.bounds,lineWidth,lineWidth)
        
        let shapeType = arc4random() % 3
        
        if shapeType == 0 {
            return UIBezierPath(roundedRect: insetRect, cornerRadius: 10.0)
        }
        
        if shapeType == 1 {
            return UIBezierPath(ovalInRect: insetRect)
        }
        return trianglePathInRect(insetRect)
    }
    
    func trianglePathInRect(rect:CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.moveToPoint(CGPointMake(rect.width / 2.0, rect.origin.y))
        path.addLineToPoint(CGPointMake(rect.width,rect.height))
        path.addLineToPoint(CGPointMake(rect.origin.x,rect.height))
        path.closePath()
        
        
        return path
    }

    func didPan(panGesture: UIPanGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        var translation = panGesture.translationInView(self)
        
        translation = CGPointApplyAffineTransform(translation, self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        panGesture.setTranslation(CGPointZero, inView: self)
    }
    
    func didPinch(pinchGesture: UIPinchGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        let scale = pinchGesture.scale
        
        self.transform = CGAffineTransformScale(self.transform, scale, scale)
        
        pinchGesture.scale = 1.0
    }
    
    func didRotate(rotationGesture: UIRotationGestureRecognizer) {
        
        self.superview!.bringSubviewToFront(self)
        
        let rotation = rotationGesture.rotation
        
        self.transform = CGAffineTransformRotate(self.transform, rotation)
        
        rotationGesture.rotation = 0.0
    }
}
