//
//  UITextView+Ext.swift
//  AATextView
//
//  Created by jianyue on 2018/11/13.
//  Copyright © 2018 LYCoder. All rights reserved.
//

import UIKit

extension UITextView {
    
    /// 开启自动调节高度功能
    func startAutomaticAdjust() {
        addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    /// 关闭自动调节功能（必须手动调用，否则会内存泄漏，引起 crash）
    public func stopAutomaticAdjust() {
        removeObserver(self, forKeyPath: "contentSize")
    }
    
    /// 高度改变时 调用
    public func callChangeHeightBlock(block: @escaping (_ height: CGFloat) -> ()) {
        callChangeHeightBlock = block
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentSize" {
            if surfaceFrame == .zero {
                isScrollEnabled = true
                
                // return键 改成 send
                returnKeyType = .send
                // 字符串为0时（send）键无效
                enablesReturnKeyAutomatically = true
                
                surfaceFrame = frame
            }
            
            // 实际被设置的高度
            let frameH = surfaceFrame.size.height
            // 文本内容的高度
            let contentH = contentSize.height
            
            // 判断内容是否超出Frame区域
            if contentH > frameH {
                // 超出了  （重新设置Frame）
                frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: contentH)
            } else {
                // 未超出  （使用外部Frame）
                frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frameH)
            }
            
            // 内边距
            var offset: UIEdgeInsets = .zero
            
            if contentSize.height <= surfaceFrame.size.height {
                let offsetTop = (surfaceFrame.size.height - contentSize.height) / 2
                offset = UIEdgeInsets(top: offsetTop, left: 0, bottom: 0, right: 0)
            } else {
                offset = .zero
            }
            contentInset = offset
            
            callChangeHeightBlock?(bounds.height)
        } else {
            
        }
    }
    
    private typealias ChangeHeightBlock = (CGFloat) -> ()
    
    private struct AssociatedKeys_AutomaticAdjust {
        static var surfaceFrame: String = "surfaceFrame"
        static var callChangeHeightBlock: String = "callChangeHeightBlock"
    }
    
    private var surfaceFrame: CGRect! {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys_AutomaticAdjust.surfaceFrame, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys_AutomaticAdjust.surfaceFrame) as? CGRect else { return .zero }
            
            return value
        }
    }
    
    private var callChangeHeightBlock: ChangeHeightBlock? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys_AutomaticAdjust.callChangeHeightBlock, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys_AutomaticAdjust.callChangeHeightBlock) as? ChangeHeightBlock else { return nil }
            
            return value
        }
    }
}
