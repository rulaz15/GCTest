//
//  AutoKeyboardScrollView.swift
//
//  Created by Honghao Zhang on 2/1/15.
//  Copyright (c) 2015 Honghao Zhang (张宏昊)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
import UIKit

public class AutoKeyboardScrollView: UIScrollView {
    
    // MARK: Public APIs
    
    /**
     Manually add textField to scrollView and let scrollView handle it
     
     :param: textField textField in subView tree of receiver
     */
    public func handleTextField(textField: UITextField) {
        (self.contentView as! ContentView).addTextField(textField: textField)
    }
    
    /**
     Manually add a bunch of textFields to scrollView and let scrollView handle them
     This is a convenience method
     
     :param: textFields Array of textFields in subView tree of receiver
     */
    public func handleTextFields(textFields: [UITextField]) {
        for field in textFields {
            handleTextField(textField: field)
        }
    }
    
    /**
     Manually remove textField to scrollView and let scrollView handle it
     
     :param: textField textField in subView tree of receiver
     */
    public func removeTextField(textField: UITextField) {
        (self.contentView as! ContentView).removeTextField(textField: textField)
    }
    
    /**
     Manually remove a bunch of textFields to scrollView and let scrollView handle them
     This is a convenience method
     
     :param: textFields Array of textFields in subView tree of receiver
     */
    public func removeTextFields(textFields: [UITextField]) {
        for field in textFields {
            removeTextField(textField: field)
        }
    }
    
    /**
     Set top and bottom margin for specific textField.
     This will give an empty spacing between active textField and keyboard
     
     - parameter margin:    margin
     - parameter textField: textField
     */
    public func setTextMargin(margin: CGFloat, forTextField textField: UITextField) {
        (contentView as! ContentView).setTextMargin(margin: margin, forTextField: textField)
    }
    
    /// Top and Bottom margin for textField, this will give an empty spacing between active textField and keyboard
    public var textFieldMargin: CGFloat = 20
    
    /// contentView's width equals to scrollView
    public var contentViewWidthEqualsToScrollView: Bool = false {
        didSet {
            self.removeConstraint(contentViewEqualWidthConstraint)
            
            contentViewEqualWidthConstraint = contentViewConstraintEqual(attr: .width)
            if contentViewWidthEqualsToScrollView {
                contentViewEqualWidthConstraint.priority = UILayoutPriority(rawValue: 1000)
            } else {
                contentViewEqualWidthConstraint.priority = UILayoutPriority(rawValue: 10)
            }
            
            self.addConstraint(contentViewEqualWidthConstraint)
        }
    }
    
    /// contentView's height equals to scrollView
    public var contentViewHeightEqualsToScrollView: Bool = false {
        didSet {
            self.removeConstraint(contentViewEqualHeightConstraint)
            
            contentViewEqualHeightConstraint = contentViewConstraintEqual(attr: .height)
            if contentViewHeightEqualsToScrollView {
                contentViewEqualHeightConstraint.priority = UILayoutPriority(rawValue: 1000)
            } else {
                contentViewEqualHeightConstraint.priority = UILayoutPriority(rawValue: 10)
            }
            
            self.addConstraint(contentViewEqualHeightConstraint)
        }
    }
    
    // All subViews should be added on contentView
    // ContentView's size determines contentSize of ScrollView
    // By default, contentView has same size as ScrollView, to expand the contentSize, let subviews' constraints to determin all four edges
    public var contentView: UIView!
    
    // MARK: - Private
    private class ContentView: UIView {
        var textFields = [UITextField]()
        var textFieldsToMargin = [UITextField : CGFloat]()
        
        /**
         addSubView: will check whether there's textField on this view, be sure to add textField before adding its container View
         
         :param: view A subview
         */
        override func addSubview(_ view: UIView) {
            super.addSubview(view)
            checkSubviewsRecursively(view: view)
        }
        
        /**
         Add all textFields from the subviews of the view into managed textFields and setup editing actions for them
         
         :param: view A target text field
         */
        private func checkSubviewsRecursively(view: UIView) {
            if let textField = view as? UITextField {
                addTextField(textField: textField)
            }
            
            // Base case
            if view.subviews.count == 0 {
                return
            }
            
            for subview in view.subviews {
                checkSubviewsRecursively(view: subview)
            }
        }
        
        /**
         Add the text field to managed textFields and setup editing actions for it
         
         :param: textField A target text field
         */
        fileprivate func addTextField(textField: UITextField) {
            textFields.append(textField)
            setupEditingActionsForTextField(textField: textField)
        }
        
        /**
         Setup text field editing actions for a text field
         
         :param: textField A target text field
         */
        private func setupEditingActionsForTextField(textField: UITextField) {
            guard let scrollView = superview as? UIScrollView else {
                print("Error: contentView's superview is not scrollView")
                return
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidBegin) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidBegin(sender:)), for: .editingDidBegin)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingChanged) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingChanged(sender:)), for: .editingChanged)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEnd) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEnd(sender:)), for: .editingDidEnd)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEndOnExit) == nil {
                textField.addTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEndOnExit(sender:)), for: .editingDidEndOnExit)
            }
        }
        
        /**
         Remove the text field from managed textFields and remove editing actions for it
         
         :param: textField A target text field
         */
        fileprivate func removeTextField(textField: UITextField) {
            
            if let index = textFields.index(of: textField) {
                textFields.remove(at: index)
                textFieldsToMargin.removeValue(forKey: textField)
            }

            removeEditingActionsForTextField(textField: textField)
        }
        
        /**
         Remove text field editing actions for a text field
         
         :param: textField A target text field
         */
        private func removeEditingActionsForTextField(textField: UITextField) {
            guard let scrollView = superview as? UIScrollView else {
                print("Error: contentView's superview is not scrollView")
                return
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidBegin) != nil {
                textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidBegin(sender:)), for: .editingDidBegin)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingChanged) != nil {
                textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingChanged(sender:)), for: .editingChanged)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEnd) != nil {
                textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEnd(sender:)), for: .editingDidEnd)
            }
            
            if textField.actions(forTarget: scrollView, forControlEvent: .editingDidEndOnExit) != nil {
                textField.removeTarget(scrollView, action: #selector(AutoKeyboardScrollView._textFieldEditingDidEndOnExit(sender:)), for: .editingDidEndOnExit)
            }
        }
        
        fileprivate func setTextMargin(margin: CGFloat, forTextField textField: UITextField) {
            guard textFields.contains(textField) else {
                assertionFailure("textField: \(textField) is not handled")
                return
            }
            
            textFieldsToMargin[textField] = margin
        }
    }
    
    private var contentViewEqualWidthConstraint: NSLayoutConstraint!
    private var contentViewEqualHeightConstraint: NSLayoutConstraint!
    
    // These two values are used to backup original states
    private var originalContentInset: UIEdgeInsets!
    private var originalContentOffset: CGPoint!
    
    // Keep values from UIKeyboardNotification
    private var keyboardFrame: CGRect!
    private var keyboardAnimationDuration: TimeInterval!
    
    // TextFields on subtrees for scrollView
    private var textFields: [UITextField] {
        get {
            return (contentView as! ContentView).textFields
        }
    }
    
    // Current editing textField
    private var activeTextField: UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Disable undesired scroll behavior of default UIScrollView
    // To Avoid undesired scroll behavior of default UIScrollView, call zhScrollRectToVisible::
    // Reference: http://stackoverflow.com/a/12640831/3164091
    override public func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        if _expectedScrollRect == nil {
            super.scrollRectToVisible(rect, animated: animated)
            return
        }
        if rect.equalTo(_expectedScrollRect) {
            super.scrollRectToVisible(rect, animated: animated)
        }
    }
    
    private var _expectedScrollRect: CGRect!
    private func zhScrollRectToVisible(rect: CGRect, animated: Bool) {
        _expectedScrollRect = rect
        scrollRectToVisible(rect, animated: animated)
    }
    
    public override func addSubview(_ view: UIView) {
        if (view is ContentView == false) && (view is UIImageView == false && view.alpha == 0) {
            print("warning: adding view on AutoKeyboardScrollView detected, you should add view on .contentView")
        }
        super.addSubview(view)
    }
    
    // MARK: Setups
    private func commonInit() {
        setupContentView()
        setupGestures()
        registerNotifications()
    }
    
    private func setupContentView() {
        contentView = ContentView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        
        let top = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        
        // Width and height constraints with a lower priority
        contentViewEqualWidthConstraint = contentViewConstraintEqual(attr: .width)
        // If equal width is not required, set its priority to a low value
        if contentViewWidthEqualsToScrollView == false {
            // Set its priority to be a very low value, to avoid conflicts
            contentViewEqualWidthConstraint.priority = UILayoutPriority(rawValue: 10)
        }
        
        contentViewEqualHeightConstraint = contentViewConstraintEqual(attr: .height)
        if contentViewHeightEqualsToScrollView == false {
            contentViewEqualHeightConstraint.priority = UILayoutPriority(rawValue: 10)
        }
        
        self.addConstraints([top, left, bottom, right, contentViewEqualWidthConstraint, contentViewEqualHeightConstraint])
    }
    
    private func contentViewConstraintEqual(attr: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: contentView, attribute: attr, relatedBy: .greaterThanOrEqual, toItem: self, attribute: attr, multiplier: 1.0, constant: 0.0)
    }
    
    deinit {
        unregisterNotifications()
    }
}

// MARK: TapGesture - Tap to dismiss
extension AutoKeyboardScrollView {
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AutoKeyboardScrollView._scrollViewTapped(gesture:)))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc(scrollViewTapped:)
    private func _scrollViewTapped(gesture: UITapGestureRecognizer) {
        activeTextField?.resignFirstResponder()
    }
}

// MARK: TextFields Actions
extension AutoKeyboardScrollView {
    @objc(_textFieldEditingDidBegin:)
    private func _textFieldEditingDidBegin(sender: AnyObject) {
        activeTextField = sender as? UITextField
        if self.keyboardFrame != nil {
            makeActiveTextFieldVisible(keyboardRect: self.keyboardFrame)
        }
    }
    
    @objc(_textFieldEditingChanged:)
    private func _textFieldEditingChanged(sender: AnyObject) {
        if self.keyboardFrame != nil {
            makeActiveTextFieldVisible(keyboardRect: self.keyboardFrame)
        }
    }
    
    @objc(_textFieldEditingDidEnd:)
    private func _textFieldEditingDidEnd(sender: AnyObject) {
        activeTextField = nil
    }
    
    @objc(_textFieldEditingDidEndOnExit:)
    private func _textFieldEditingDidEndOnExit(sender: AnyObject) {
        // This method gives the ability of dismissing keyboard on tapping return
    }
}

// MARK: Keyboard Notification
extension AutoKeyboardScrollView {
    private func registerNotifications() {
        // Reason for only registering UIKeyboardWillChangeFrameNotification
        // Since UIKeyboardWillChangeFrameNotification will be posted before willShow and willBeHidden, to avoid duplicated animations, detecting keyboard behaviors only from this notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AutoKeyboardScrollView.keyboardWillChange(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc(keyboardWillChange:)
    private func keyboardWillChange(notification: NSNotification) {
        // Init keyboardAnimationDuration
        keyboardAnimationDuration = keyboardDismissingDuration(notification: notification)
        
        if isKeyboardWillShow(notification: notification) {
            // Preserved original contentInset and contentOffset
            originalContentInset = contentInset
            originalContentOffset = contentOffset
            
            let endFrame = keyboardEndFrame(notification: notification)
            // Init keyboardFrame
            keyboardFrame = endFrame
            
            makeActiveTextFieldVisible(keyboardRect: endFrame)
        } else if isKeyboardWillHide(notification: notification) {
            // Animated to restore to original state
            UIView.animate(withDuration: keyboardDismissingDuration(notification: notification), animations: { () -> Void in
                self.contentInset = self.originalContentInset ?? .zero
                self.contentOffset = self.originalContentOffset ?? .zero
            }, completion: { (completed) -> Void in
                self.keyboardFrame = nil
            })
        } else {
            // This will be called when keyboard size is changed when it's still displaying
            let endFrame = keyboardEndFrame(notification: notification)
            self.keyboardFrame = endFrame
            makeActiveTextFieldVisible(keyboardRect: endFrame)
        }
    }
    
    /**
     Make sure active textField is visible
     Note: scrollView's contentInset will be changed
     
     :param: keyboardRect Current keyboard frame
     */
    private func makeActiveTextFieldVisible( keyboardRect: CGRect) {
        var keyboardRect = keyboardRect
        guard let activeTextField = activeTextField else {
            print("Warning: activeTextField is nil")
            return
        }
        
        // flipLandscapeFrameForIOS7 only changes CGRect for landscape on iOS7
        keyboardRect = flipLandscapeFrameForIOS7(frame: keyboardRect)
        
        // VisibleScrollViewFrame
        var visibleScrollFrame = convert(bounds, to: nil)
        visibleScrollFrame = flipLandscapeFrameForIOS7(frame: visibleScrollFrame)
        
        // If keyboard covers part of visibleScrollFrame, cut off visibleScrollFrame and update scrollView's contentInset
        let bottomOfScrollView = visibleScrollFrame.maxY
        if bottomOfScrollView > keyboardRect.origin.y {
            let cutHeight = bottomOfScrollView - keyboardRect.origin.y
            visibleScrollFrame.size.height -= cutHeight
            
            // Animated change self.contentInset
            UIView.animate(withDuration: keyboardAnimationDuration, animations: { () -> Void in
                self.contentInset = UIEdgeInsets.init(top: self.contentInset.top, left: self.contentInset.left, bottom: cutHeight, right: self.contentInset.right)
            }, completion: nil)
        }
        
        // Enlarge the targetFrame, give top and bottom some points margin
        var targetFrame = flipLandscapeFrameForIOS7(frame: activeTextField.convert(activeTextField.bounds, to: self))
        
        // Add top & bottom margins for target frame
        let textFieldMargin = (contentView as! ContentView).textFieldsToMargin[activeTextField] ?? self.textFieldMargin
        targetFrame.origin.y -= textFieldMargin
        targetFrame.size.height += textFieldMargin * 2
        
        // Don't call default scrollRectToVisible
        self.zhScrollRectToVisible(rect: targetFrame, animated: true)
    }
    
    // Helper functions
    private func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    private func keyboardBeginFrame(notification: NSNotification) -> CGRect {
        return ((notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue as CGRect?)!
    }
    
    private func keyboardEndFrame(notification: NSNotification) -> CGRect {
        return ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue as CGRect?)!
    }
    
    private func isKeyboardWillShow(notification: NSNotification) -> Bool {
        let beginFrame = keyboardBeginFrame(notification: notification)
        return (abs(beginFrame.origin.y - screenHeight()) < 0.1)
    }
    
    private func isKeyboardWillHide(notification: NSNotification) -> Bool {
        let endFrame = keyboardEndFrame(notification: notification)
        return (abs(endFrame.origin.y - screenHeight()) < 0.1)
    }
    
    private func keyboardDismissingDuration(notification: NSNotification) -> TimeInterval {
        return ((notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue as TimeInterval?)!
    }
    
    private func isIOS7() -> Bool { return floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1) }
    
    private func isLandscapeMode() -> Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    
    /**
     Flip frame for landscape on iOS7
     Since on landscape on iOS7, CGRect's origin and size is same as portrait, need to flip the rect to let it reflect true width and height
     
     :param: frame Original CGRect
     
     :returns: Flipped CGRect
     */
    private func flipLandscapeFrameForIOS7(frame: CGRect) -> CGRect {
        if isIOS7() && isLandscapeMode() {
            let newFrame = CGRect(x: frame.origin.y, y: frame.origin.x, width: frame.size.height, height: frame.size.width)
            return newFrame
        } else {
            return frame
        }
    }
}
