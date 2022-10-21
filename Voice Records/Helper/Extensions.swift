//
//  Extension.swift
//  Waydari
//
//  Created by Ravi's mac on 13/06/18.
//  Copyright © 2018 macOs. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AudioToolbox
import SDWebImage
import Accelerate
import Security
import MobileCoreServices
import WebKit
import SVProgressHUD

// MARK:- Constants

func mandatoryMark(_ color: UIColor) -> NSAttributedString {
    
    let mark = " *"
    let attrib = NSAttributedString(string: mark, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: color])
    return attrib
}

func setAfter(_ delay: Double = 0.01, closure: @escaping @convention(block) () -> Swift.Void) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

func takeScreenshot() -> UIImage? {
  
    var screenshotImage :UIImage?
    let layer = UIApplication.shared.keyWindow!.layer
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
    guard let context = UIGraphicsGetCurrentContext() else {return nil}
    layer.render(in:context)
    screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return screenshotImage
}

extension UserDefaults {
    
    class func saveCustomData<T:Encodable>(_ customData: T, forKey: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(customData) {
            UserDefaults.standard.set(encoded, forKey: forKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    class func getCustomData<T:Decodable>(_ modelType: T.Type, forKey: String) -> T? {
        
        if let savedPerson = UserDefaults.standard.object(forKey: forKey) as? Data {
            let decoder = JSONDecoder()
            if let model = try? decoder.decode(T.self, from: savedPerson) {
                return model
            }
        }
        return nil
    }
}

// MARK: -   Play System Sound
class Sound {
    static var soundID: SystemSoundID = 0
    static func install(_ fileName: String = "", ext: String = "", soundiD: SystemSoundID = 0) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else { return  }
        soundID = soundiD
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
    }
    static func play() {
        guard soundID != 0 else { return }
        AudioServicesPlaySystemSound(soundID)
    }
    static func dispose() {
        guard soundID != 0 else { return }
        AudioServicesDisposeSystemSoundID(soundID)
    }
}

// MARK: -   PHAsset

extension PHAsset {
    
    var originalFilename: String? {
        
        var fname:String?
        
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fname = resource.originalFilename
            }
        }
        
        if fname == nil {
            fname = self.value(forKey: "filename") as? String
        }
        return fname
    }
}

// MARK: -   UIStoryboard

extension UIStoryboard {
    
    convenience init(_ name: Storyboard = .Main) {
        self.init(name: name.rawValue, bundle: Bundle.main)
    }
    
    class func instantiateVC<T>(_ vc: T.Type, _ name: Storyboard = .Main) -> T {
        guard let vcType = UIStoryboard(name).instantiateViewController(withIdentifier: String(describing: vc)) as? T else {
            fatalError(String(describing: vc) + " identifier not found")
        }
        return vcType
    }
}

// MARK: -  Sequence
extension Sequence where Iterator.Element == UIView {
    
    func setRound() {
        self.forEach { (v) in
            v.setRound()
        }
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        self.forEach { (v) in
            v.cornerRadius = radius
        }
    }
    
    func setRoundBorder(_ width: CGFloat, _ color: String) {
        self.forEach { (v) in
            v.setRoundBorder(width, color)
        }
    }
    
    func setBorder(_ width: CGFloat, _ color: String, _ cornerRadius: CGFloat) {
        self.forEach { (v) in
            v.setBorder(width, color, cornerRadius)
        }
    }
    
    func setShadow(_ radius: CGFloat, _ width: CGFloat, _ height: CGFloat, _ color:String = "686868", _ opacity: Float = 1.0) {
        self.forEach { (v) in
            v.setShadow(radius, width, height, color, opacity)
        }
    }
}

extension Sequence where Iterator.Element == UITextField {
    
    func setUnderLine(_ color : UIColor) {
        self.forEach { (v) in
            v.setUnderLine(color)
        }
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        self.forEach { (v) in
            v.cornerRadius = radius
        }
    }
    
    func setRoundBorder(_ width: CGFloat, _ color: String) {
        self.forEach { (v) in
            v.setRoundBorder(width, color)
        }
    }
    
    func setBorder(_ width: CGFloat, _ color: String, _ cornerRadius: CGFloat) {
        self.forEach { (v) in
            v.setBorder(width, color, cornerRadius)
        }
    }
    
    func setBlankView(_ width: CGFloat, _ side: Side = .Left) {
        self.forEach { (v) in
            v.setBlankView(width, side)
        }
    }
    
    func setView(_ image: UIImage, _ width: CGFloat, _ imageWidth: CGFloat, _ side: Side = .Left) {
        self.forEach { (v) in
            v.setView(image, width, imageWidth, side)
        }
    }
    
    func setLeftSemantic() {
        self.forEach { (tf) in
            tf.setLeftSemantic()
        }
    }
    
    func setRightSemantic() {
        self.forEach { (tf) in
            tf.setRightSemantic()
        }
    }
}

extension Sequence where Iterator.Element == UITextView {
    
    func setUnderLine(_ color : UIColor) {
        self.forEach { (v) in
            v.setUnderLine(color)
        }
    }
    
}


// MARK: -   UIWindow
extension UIWindow {
    
    func setRoot<T: UIViewController>(_ vc: T.Type, storyboard: Storyboard = .Main) -> Self {
        self.rootViewController = UIStoryboard.instantiateVC(vc, storyboard)
        return self
    }
    
    func setRootVC(_ vc: UIViewController) -> UIWindow {
        self.rootViewController = vc
        return self
    }
}

// MARK: -  UINavigationController
extension UINavigationController: UIGestureRecognizerDelegate {
    
    func popToVC<T: UIViewController>(_ viewcontroller: T.Type, animted: Bool = true) {
        for vc in self.viewControllers {
            if vc.isKind(of: viewcontroller) {
                self.popToViewController(vc, animated: animted)
                break
            }
        }
    }
    
    /*------******* START - Swipe to back gesture *******------*/
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    /*------******* END - Swipe to back gesture *******------*/
}



// MARK: -  UIViewControler
extension UIViewController {
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func showVC<T : UIViewController>(_ vc: T.Type, storyboard: Storyboard = .Main) {
        
        let vcinstance = UIStoryboard.instantiateVC(vc, storyboard)
        if let nav = navigationController {
            nav.show(vcinstance, sender: nil)
        }
        else {
            self.present(vcinstance, animated: true, completion: nil)
        }
    }
    
    func pushVC<T : UIViewController>(_ vc: T.Type, storyboard: Storyboard = .Main, animated: Bool = true) {
        
        let vcinstance = UIStoryboard.instantiateVC(vc, storyboard)
        if let nav = navigationController {
            nav.pushViewController(vcinstance, animated: animated)
        }
    }
    
    func backVC() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func alertWith(_ title: String? = AppName, message: String?, type: UIAlertController.Style = UIAlertController.Style.alert, cancelTitle:String? = "OK",  othersTitle: [String] = [], sheetSourceView: UIView? = nil, cancelTap:(()->())? = nil, othersTap: ((_ index: Int, _ title: String)->())? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: type)
        
        if othersTitle .count > 0 {
            
            for (index, str) in othersTitle.enumerated() {
                
                alert.addAction(UIAlertAction(title: str, style: .default, handler: { (action) in
                    othersTap?(index, str)
                }))
            }
        }
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .destructive, handler: { (action) in
            cancelTap?()
        }))
        
        if type == .actionSheet, sheetSourceView != nil, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            alert.popoverPresentationController?.permittedArrowDirections = .any
            alert.popoverPresentationController?.sourceView = sheetSourceView
            alert.popoverPresentationController?.sourceRect = sheetSourceView!.bounds
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func errorAlert(_ title: String = AppName, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func successAlert(_ title: String = AppName, message: String,button :String = "OK", doneAction:(()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
            if doneAction != nil {
                doneAction!()
            }
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func getNavVC<T : UIViewController>(_ vc: T.Type, storyboard: Storyboard = .Main) -> UINavigationController {
        
        let vc = UIStoryboard.instantiateVC(vc, storyboard)
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        return nav
    }
    
}

// MARK: - UIPageViewController
extension UIPageViewController {
    
    func addPageControllerInto(_ vc: UIViewController, containerView: UIView) {
        
        dataSource = vc as? UIPageViewControllerDataSource
        delegate = vc as? UIPageViewControllerDelegate
        
        vc.addChild(self)
        self.didMove(toParent: vc)
        
        containerView.addSubview(self.view)
        self.view.addSurroundConstraintIn(containerView)
    }
}

// MARK: -  UIView

extension UIView {
    
    func blink(duration: TimeInterval = 0.8, delay: TimeInterval = 0.0, alpha: CGFloat = 0.0) {
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
                self.alpha = alpha
            })
        }
    
    public func setShadowView(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    func drawDottedLine() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.

        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: self.bounds.minX, y: self.bounds.minY), CGPoint(x: self.bounds.maxX, y: self.bounds.minY)])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    func snapshot() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func constraintWithIdentifier(_ identifier: String) -> NSLayoutConstraint? {
        return self.constraints.first { $0.identifier == identifier }
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
    static func loadNib<T: UIView>(viewType: T.Type) -> T {
        let className = String.className(aClass: viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    func fixInView(_ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    static func loadNib() -> Self {
        return loadNib(viewType : self)
    }
    
    static func getView<T>(viewT: T.Type) -> T {
        
        let v = UINib(nibName: String(describing: viewT), bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as! T
        return v
    }
    
    static func viewFromNibName(_ name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views?.first as? UIView
    }
    
    func addSurroundConstraintIn(_ containerView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func setRound() {
        self.cornerRadius = self.frame.width/2
    }
    
    func setRoundBorder(_ width: CGFloat, _ color: String) {
        setRound()
        setBorder(width, color)
    }
    
    func setBorder(_ width: CGFloat, _ color: String) {
        self.layer.borderColor = UIColor(color).cgColor
        self.layer.borderWidth = width
    }
    
    func setBorder(_ width: CGFloat, _ color: String, _ cornerRadius: CGFloat) {
        self.layer.borderColor = UIColor(color).cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = cornerRadius
    }
    
    func setShadow(_ radius: CGFloat, _ width: CGFloat, _ height: CGFloat, _ color:String = "686868", _ opacity: Float = 1.0) {
        self.layer.shadowColor = UIColor(color).cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func Set_boder_white( _ borderColor: String = "ffffff",_ Corners: UIRectCorner = [.topRight, .bottomLeft])
    {
        let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: Corners, cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer.init()
        borderLayer.frame = self.bounds
        borderLayer.path = maskPath.cgPath
        borderLayer.lineWidth = 4
        borderLayer.strokeColor = UIColor(borderColor).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(borderLayer)
    }
    
    func Set_Corner(_ Corners: UIRectCorner,_ radius: CGFloat, borderLayer name: String? = nil, borderWidth: CGFloat = 0.0, borderColor color: String = "ffffff", backgoundColor: String = "") {
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: Corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = maskPath
        self.layer.mask = rectShape
        
        if name != nil {
            
            if let layers = self.layer.sublayers {
                for layer1 in layers {
                    if layer1.name == name! {
                        layer1.removeFromSuperlayer()
                    }
                }
            }
            
            let borderLayer = CAShapeLayer.init()
            borderLayer.frame = self.bounds
            borderLayer.path = maskPath
            borderLayer.lineWidth = borderWidth
            borderLayer.strokeColor = UIColor(color).cgColor
            borderLayer.name = name!
            borderLayer.backgroundColor = backgoundColor == "" ? UIColor.clear.cgColor : UIColor(backgoundColor).cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            self.layer.insertSublayer(borderLayer, at: 0)
        }
    }
    
    
    func setCornersBorders(for corners: UIRectCorner, radii: CGFloat, removeBorderSide: [BorderSide], borderThickness: CGFloat, borderColor: String) {
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii)).cgPath
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = frame
        rectShape.position = center
        rectShape.path = maskPath
        layer.mask = rectShape
        
        if let lays = layer.sublayers {
            for lay in lays {
                if lay.name == "all" {
                    lay.removeFromSuperlayer()
                }
            }
        }
        
        let borderlayer1 = CAShapeLayer()
        borderlayer1.path = maskPath
        borderlayer1.fillColor = UIColor.clear.cgColor
        borderlayer1.strokeColor = UIColor(borderColor).cgColor
        borderlayer1.lineWidth = borderThickness
        borderlayer1.name = "all"
        layer.addSublayer(borderlayer1)
        
        if !removeBorderSide.contains(.all) {
            for border in removeBorderSide {
                
                if let lays = layer.sublayers {
                    for lay in lays {
                        if lay.name == String(describing: border) {
                            lay.removeFromSuperlayer()
                        }
                    }
                }
                
                let borderlayer = CAShapeLayer()
                borderlayer.borderColor = backgroundColor!.cgColor
                borderlayer.borderWidth = borderThickness
                borderlayer.name = String(describing: border)
                
                let thick = borderThickness
                
                if border == .top {
                    borderlayer.frame = CGRect(x: thick/2, y: 0, width: frame.width, height: thick)
                }
                if border == .bottom {
                    borderlayer.frame = CGRect(x: thick/2, y: frame.height-thick, width: frame.width-thick, height: thick)
                }
                if border == .left {
                    borderlayer.frame = CGRect(x: 0, y: thick/2, width: thick, height: frame.height-thick)
                }
                if border == .right {
                    borderlayer.frame = CGRect(x: frame.width - thick, y: thick/2, width: thick, height: frame.height-thick)
                }
                layer.addSublayer(borderlayer)
            }
        }
    }
    
    func removeBorderLayer(of borders:[BorderSide]) {
        
        func remove(_ bordersArr:[BorderSide]) {
            for border in bordersArr {
                if let lays = layer.sublayers {
                    for lay in lays {
                        print("&&&&&&")
                        print(lay.name!)
                        print(String(describing: border))
                        if lay.name == String(describing: border) {
                            lay.removeFromSuperlayer()
                        }
                    }
                }
            }
        }
        
        if borders.contains(.all) {
            let names : [BorderSide] = [.left, .right, .top, .bottom, .all]
            remove(names)
        }
        else {
            remove(borders)
        }
    }
    
    
    func setBorder(for borderSide: [BorderSide], borderThickness: [CGFloat], borderColor: [String]) {
        
        if borderSide.count == borderThickness.count && borderSide.count == borderColor.count {
            if !borderSide.contains(.all) {
                for (index,border) in borderSide.enumerated() {
                    
                    if let lays = layer.sublayers {
                        for lay in lays {
                            if lay.name == String(describing: border) {
                                lay.removeFromSuperlayer()
                            }
                        }
                    }
                    
                    let borderlayer = CAShapeLayer()
                    borderlayer.borderColor = UIColor(borderColor[index]).cgColor
                    borderlayer.borderWidth = borderThickness[index]
                    borderlayer.name = String(describing: border)
                    
                    let thick = borderThickness[index]
                    
                    if border == .top {
                        borderlayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: thick)
                    }
                    if border == .bottom {
                        borderlayer.frame = CGRect(x: 0, y: frame.height-thick, width: frame.width, height: thick)
                    }
                    if border == .left {
                        borderlayer.frame = CGRect(x: 0, y: 0, width: thick, height: frame.height)
                    }
                    if border == .right {
                        borderlayer.frame = CGRect(x: frame.width - thick, y: 0, width: thick, height: frame.height)
                    }
                    layer.addSublayer(borderlayer)
                }
            }
            else {
                if let lays = layer.sublayers {
                    for lay in lays {
                        if lay.name == "allborder"{
                            lay.removeFromSuperlayer()
                        }
                    }
                }
                
                let maskPath = UIBezierPath(rect: frame).cgPath
                let borderlayer1 = CAShapeLayer()
                borderlayer1.path = maskPath
                borderlayer1.fillColor = UIColor.clear.cgColor
                borderlayer1.strokeColor = UIColor("").cgColor
                borderlayer1.lineWidth = 0.0
                borderlayer1.name = "allborder"
                layer.addSublayer(borderlayer1)
            }
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.addSublayer(gradient)
    }
    
    func applyGradient1(colours: [UIColor]) -> Void {
        self.applyGradient1(colours: colours, locations: [0.2,0.5,1.0])
    }
    
    func TextGradient(colours: [UIColor]) -> Void {
        self.applyGradient1(colours: colours, locations: [0.2,0.5,1.0])
    }
    
    func applyGradient1(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = colours.map { $0.cgColor }
        gradient.frame = self.bounds
        gradient.locations = locations
        self.layer.addSublayer(gradient)
    }
    
    var Getwidth : CGFloat {
        get { return self.frame.size.width  }
        set { self.frame.size.width = newValue }
    }
    
    var GetHeight : CGFloat {
        get { return self.frame.size.height  }
        set { self.frame.size.height = newValue }
    }
    
    var Getsize:       CGSize  { return self.frame.size}
    
    var Getorigin:     CGPoint { return self.frame.origin }
    var Getx : CGFloat {
        get { return self.frame.origin.x  }
        set { self.frame.origin.x = newValue }
    }
    
    var Gety : CGFloat {
        get { return self.frame.origin.y  }
        set { self.frame.origin.y = newValue }
    }
    
    var Getleft:       CGFloat { return self.frame.origin.x }
    var Getright:      CGFloat { return self.frame.origin.x + self.frame.size.width }
    var Gettop:        CGFloat { return self.frame.origin.y }
    var Getbottom:     CGFloat { return self.frame.origin.y + self.frame.size.height }
    
    
//    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
//    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

//    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
//
//    @IBInspectable
//    var shadowRadius: CGFloat {
//        get {
//            return layer.shadowRadius
//        }
//        set {
//            layer.shadowColor = UIColor.black.cgColor
//            layer.shadowOffset = CGSize(width: 0, height: 2)
//            layer.shadowOpacity = shadowOpacity
//            layer.shadowRadius = shadowRadius
//        }
//    }
//
//    @IBInspectable
//    var shadowColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.shadowColor!)
//        }
//        set {
//            layer.shadowColor = newValue!.cgColor
//            layer.shadowOffset = CGSize(width: 0, height: 2)
//            layer.shadowOpacity = shadowOpacity
//            layer.shadowRadius = shadowRadius
//        }
//    }
//
//    @IBInspectable
//    var shadowOffset: CGSize {
//        get {
//            return layer.shadowOffset
//        }
//        set {
//            layer.shadowColor = shadowColor?.cgColor
//            layer.shadowOffset = newValue
//            layer.shadowOpacity = shadowOpacity
//            layer.shadowRadius = shadowRadius
//        }
//    }
//
//    @IBInspectable
//    var shadowOpacity: Float {
//        get {
//            return layer.shadowOpacity
//        }
//        set {
//            layer.shadowColor = shadowColor?.cgColor
//            layer.shadowOffset = shadowOffset
//            layer.shadowOpacity = newValue
//            layer.shadowRadius = shadowRadius
//        }
//    }
//
//    @IBInspectable
//    var enableMaskBound: Bool {
//        get {
//            return layer.masksToBounds
//        }
//        set {
//            layer.masksToBounds = enableMaskBound
//        }
//    }
    
}

extension UIScreen {
    
    class var height : CGFloat {
        get { return UIScreen.main.bounds.height }
    }
    
    class var Width : CGFloat {
        get { return UIScreen.main.bounds.width }
    }
}

// MARK: -  UIColor

extension UIColor {
    convenience init(_ hex:String, _ alpha:CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner            = Scanner(string: hex as String)
        
        if (hex.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

// MARK: -   String

extension String {
    
    public func getDateWithFormate(formate: String, timezone: String?) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        
        if timezone != nil {
            formatter.timeZone = TimeZone(abbreviation: timezone!)
        }
        
        
        return formatter.date(from: self)! as Date
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func stringToDate(dateFormat: String) -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "en_US")
        dateFormater.dateFormat = dateFormat
        if let date = dateFormater.date(from: self) {
            return date
        }
        return nil
    }
    
    static func className(aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
//    func md5() -> String {
//
//        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
//        var digest = Array<UInt8>(repeating:0, count:Int(16))
//        CC_MD5_Init(context)
//        CC_MD5_Update(context, self , CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
//        CC_MD5_Final(&digest, context)
//        //context.deallocate(capacity: 1)
//        var hexString = ""
//        for byte in digest {
//            hexString += String(format:"%02x", byte)
//        }
//
//        return hexString
//    }
    
    var attributed : NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    func colored(with color: UIColor) -> NSAttributedString {
        return NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.foregroundColor : color])
    }
    
    var trimed: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    var isEmptyOrWhiteSpace : Bool {
        return (self.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted)?.isEmpty ?? true)
    }
    
//    var localized : String {
//        return MyLocalized.setLocalize(self)
//    }
    
    // Output Like: Kmphasis@123
    var isValidPassword: Bool {
//        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{3,}$"      // Old
        let passwordRegEx = "^(?=.*[0-9])(?=.*[A-Z])(?=.*[@#$%^&+=!])(?=\\S+$).{4,}$"                   // Vicky android regex
        
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
    
    var validateEmail : Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.trimed)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func toDate(_ dateFormat: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        return df.date(from: self)
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func htmlAttributed(family: String?, size: CGFloat, color: UIColor, alignment: String = "left") -> NSAttributedString? {
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-size: \(size)px !important;" +
                "color: #\(color) !important;" +
                "font-family: \(family ?? "Helvetica"), Helvetica !important;" + "text-align: \(alignment);" +
            "}</style> \(self)"
            
            
            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    func checkCapitalLetter() -> Bool {

        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: self)
        
        return capitalresult

    }
    
    func checkNumber() -> Bool {

        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: self)
        
        return numberresult

    }
    
    func checkSpecialCharacter() -> Bool {

        let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = texttest2.evaluate(with: self)
        
        return specialresult

    }
}


extension NSAttributedString {
    
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}

// MARK: -   Dateformatter

extension DateFormatter {
    
    func getMMMDateStringFrom(_ date: Date) -> String {
        
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy"
        return df.string(from: date)
    }
    
    class func getTime(_ forDate: NSDate) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "h:mm a"
        return dformatter.string(from: forDate as Date)
    }
    
    class func getDate(_ forDate: String) -> Date {
        
        let dformatter = DateFormatter()
        dformatter.dateStyle = .medium
        return dformatter.date(from: forDate)!
    }
    
    class func relativeTo(_ date: Date) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateStyle = .medium
        dformatter.doesRelativeDateFormatting = true
        return dformatter.string(from: date)
    }
}

// MARK: -   Date
extension Date {
    
    public func getDateStringWithFormate(_ formate: String, timezone: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        formatter.timeZone = TimeZone(abbreviation: timezone)
        return formatter.string(from: self)
    }
    
    static func stringToDate(_ stringDate: String, dateFormat: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: stringDate) ?? Date()
    }
    
    func dateToString(_ date: Date, dateFormat: String) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = dateFormat
        return dateFormater.string(from: date)
    }
    
    func mediumStyle() -> String {
        let dateFormater = DateFormatter()
        dateFormater.timeStyle = .medium
        //    dateFormater.locale = NSLocale(localeIdentifier:"en_US_POSIX")
        
        if NSCalendar.current.isDateInToday(self as Date) {
            if is24Hour() {
                dateFormater.dateFormat = "HH:mm"
            }
            else {
                dateFormater.dateFormat = "hh:mm"
            }
            return "Today \(dateFormater.string(from: self as Date))"
        } else {
            dateFormater.dateFormat = "MMM dd, yyyy"
            return dateFormater.string(from: self as Date)
        }
    }
    
    func is24Hour() -> Bool {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        return dateFormat.firstIndex( of: "a") == nil
    }
    
    func isGreaterThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    func remove(daysToRemove: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToRemove) * -60 * -60 * -24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    func addMonth(n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    
    func toShortTypeString() -> String {
        let formatterDate = DateFormatter()
        formatterDate.dateStyle = .short
        formatterDate.timeStyle = .short
        return formatterDate.string(from: self)
    }
    
    func hour() -> Int{
        return Calendar.current.component(.hour, from: self)
    }
    
    func day() -> Int{
        return Calendar.current.component(.day, from: self)
    }
    
    func year() -> Int{
        return Calendar.current.component(.year, from: self)
    }
    
    var timeAgoSinceNow: String {
        return getTimeAgoSinceNow()
    }
    private func getTimeAgoSinceNow() -> String {
        var interval = Calendar.current.dateComponents([.year], from: self, to: Date()).year!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " year ago" : "\(interval)" + " years ago"
        }
        interval = Calendar.current.dateComponents([.month], from: self, to: Date()).month!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " month ago" : "\(interval)" + " months ago"
        }
        interval = Calendar.current.dateComponents([.day], from: self, to: Date()).day!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " day ago" : "\(interval)" + " days ago"
        }
        interval = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " hour ago" : "\(interval)" + " hours ago"
        }
        interval = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " minute ago" : "\(interval)" + " minutes ago"
        }
        return "Now"
    }
}

// MARK: - UIResponder
extension UIResponder {
    
    func firstAvailableViewController() -> UIViewController? {
        return self.traverseResponderChainForFirstViewController()
    }
    
    func firstAvailableTableView() -> UITableView? {
        return self.traverseResponderChainForFirstTableView()
    }
    
    func traverseResponderChainForFirstViewController() -> UIViewController? {
        if let nextResponder = self.next {
            if nextResponder is UIViewController {
                return nextResponder as? UIViewController
            } else if nextResponder is UIView {
                return nextResponder.traverseResponderChainForFirstViewController()
            } else {
                return nil
            }
        }
        return nil
    }
    
    func traverseResponderChainForFirstTableView() -> UITableView? {
        if let nextResponder = self.next {
            if nextResponder is UITableView {
                return nextResponder as? UITableView
            } else if nextResponder is UIView {
                return nextResponder.traverseResponderChainForFirstTableView()
            } else {
                return nil
            }
        }
        return nil
    }
}

// MARK: -  UITableView
extension UITableView {
    
    func EmptyMessage(message:String) {
        
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.Getwidth, height: self.GetHeight))
        let messageLabel = UILabel(frame: rect)
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: AppFont.RoobertSemiBold, size: 20)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    var setContentInset : (CGFloat?,CGFloat?,CGFloat?,CGFloat?) {
        set {
            let inset = contentInset
            contentInset = UIEdgeInsets(top: newValue.0 ?? inset.top, left: newValue.1 ?? inset.left, bottom: newValue.2 ?? inset.bottom, right: newValue.3 ?? inset.right)
        }
        get {
            return (contentInset.top, contentInset.left, contentInset.bottom, contentInset.right)
        }
    }
    
    func dequeCell<T>(_ cell: T.Type, indexPath: IndexPath) -> T {
        let cell1 = dequeueReusableCell(withIdentifier: String(describing: cell), for: indexPath) as! T
        return cell1
    }
    
    func registerNib<T>(_ cell: T.Type) {
        let str = String(describing: T.self)
        self.register(UINib(nibName: str, bundle: Bundle.main), forCellReuseIdentifier: str)
    }
}

// MARK: -  UITableView
extension UICollectionView {
    
    func EmptyMessage(message:String) {
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: AppFont.RoobertSemiBold, size: 17)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
    }
    
    func dequeCell<T>(_ cell: T.Type, indexPath: IndexPath) -> T {
        let cell1 = dequeueReusableCell(withReuseIdentifier: String(describing: cell), for: indexPath) as! T
        return cell1
    }
    
    func registerNib<T>(_ cell: T.Type) {
        let str = String(describing: T.self)
        self.register(UINib(nibName: str, bundle: Bundle.main), forCellWithReuseIdentifier: str)
    }
    
}

// MARK: -   UITextField
enum Side {
    case Left
    case Right
}

public enum BorderSide {
    case top
    case bottom
    case left
    case right
    case all
}

// MARK: -   UITextView

extension UITextView : NSTextStorageDelegate{
    
    // scale font
    override open func awakeFromNib() {
        super.awakeFromNib()
    
        
//        guard let fontName = self.font?.fontName,
//            let fontSize = self.font?.pointSize else { return }
//        self.font = UIFont(name: fontName, size: fontSize * CGFloat(RATIO.SCREEN))
    }
    
//    @IBInspectable var localizeKey: String {
//        get {
//            return ""
//        } set {
//            self.text = MyLocalized.setLocalize(newValue)
//        }
//    }
    
    class PlaceholderLabel: UILabel { }
    
    var placeholderLabel: PlaceholderLabel {
        if let label = subviews.compactMap( { $0 as? PlaceholderLabel }).first {
            return label
        } else {
            let label = PlaceholderLabel(frame: .zero)
            label.font = font
            addSubview(label)
            return label
        }
    }
    
    @IBInspectable
    var extPlaceholder: String {
        get {
            return subviews.compactMap( { $0 as? PlaceholderLabel }).first?.text ?? ""
        }
        set {
            let placeholderLabel = self.placeholderLabel
            placeholderLabel.text = newValue
            placeholderLabel.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
            placeholderLabel.numberOfLines = 0
            let width = frame.width - textContainer.lineFragmentPadding * 2
            let size = placeholderLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            placeholderLabel.frame.size.height = size.height + 4
            placeholderLabel.frame.size.width = width
            placeholderLabel.frame.origin = CGPoint(x: textContainer.lineFragmentPadding, y: textContainerInset.top)
            
            textStorage.delegate = self
            
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
//    @IBInspectable var placeholderLocalizeKey: String {
//        get {
//            return ""
//        } set {
//            let placeholderLabel = self.placeholderLabel
//            placeholderLabel.text = MyLocalized.setLocalize(newValue)
//        }
//    }
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    func setUnderLine(_ color : UIColor) {
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func updateWithSpacing(lineSpacing: Float) {
        
        let attributedString = NSMutableAttributedString(string: self.text!)
        let mutableParagraphStyle = NSMutableParagraphStyle()
        
        mutableParagraphStyle.lineSpacing = CGFloat(lineSpacing)
        
        if let stringLength = self.text?.count {
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: mutableParagraphStyle, range: NSMakeRange(0, stringLength))
            attributedString.addAttribute(NSAttributedString.Key.font , value:  self.font!, range: NSMakeRange(0, stringLength))
        }
        self.attributedText = attributedString
    }
}


// MARK: -
// MARK: -   UITextField

extension UITextField {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.font = UIFont(name: self.font!.fontName, size: setCustomFont(self.font!.pointSize))
        
    }
    
//    @IBInspectable var placeholderLocalizeKey: String {
//        get {
//            return ""
//        } set {
//            self.placeholder = MyLocalized.setLocalize(newValue)
//        }
//    }
//
//    @IBInspectable var localizeKey: String {
//        get {
//            return ""
//        } set {
//            self.text = MyLocalized.setLocalize(newValue)
//        }
//    }

    func setInputViewDatePicker(target: Any, selector: Selector) {
        
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .dateAndTime
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
    func setUnderLine(_ color : UIColor) {
        let border = CALayer()
        let width = CGFloat(0.25)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func setBlankView(_ width: CGFloat, _ side: Side = .Left) {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        
        if side == .Left {
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        else if side == .Right {
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
    func setView(_ image: UIImage, _ width: CGFloat, _ imageWidth: CGFloat, _ side: Side = .Left) {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.GetHeight))
        let imgview = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth))
        imgview.image = image
        imgview.center = paddingView.center
        paddingView.addSubview(imgview)
        
        let tapOnImgview = UITapGestureRecognizer(target: self, action: #selector(tapOnImgView(_:)))
        tapOnImgview.numberOfTapsRequired = 1
        paddingView.addGestureRecognizer(tapOnImgview)
        
        if side == .Left {
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        else if side == .Right {
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
    @objc func tapOnImgView(_ recognizer: UITapGestureRecognizer) {
        self.becomeFirstResponder()
    }
    
    public func setRightSemantic() {
        self.semanticContentAttribute = .forceRightToLeft
        self.textAlignment = .right
    }
    
    func setLeftSemantic() {
        self.semanticContentAttribute = .forceLeftToRight
        self.textAlignment = .left
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}



// MARK: -
// MARK: -   UILable
extension UILabel {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.font =  UIFont(name: self.font.fontName, size: setCustomFont(self.font.pointSize))
            
        
//        print("***************\n"+text!)
//        let fontName = self.font!.fontName
//        let fontSize = self.font!.pointSize
//        print(self.font!.pointSize)
//        self.font = UIFont(name: fontName, size: fontSize * CGFloat(RATIO.SCREEN))
//        print(self.font!.pointSize)
    }
    
//    @IBInspectable var localizeTextKey: String {
//        get {
//            return ""
//        } set {
//            self.text = MyLocalized.setLocalize(newValue)
//        }
//    }
    
    var getLableHeight: CGFloat {
        let height = text!.height(withConstrainedWidth: Getwidth, font: font)
        return height
    }
    
    func applyLineSpace(_ space: CGFloat) {
        
        let attribStr = NSMutableAttributedString(attributedString: self.attributedText!)
        let paragStyle = NSMutableParagraphStyle()
        paragStyle.lineSpacing = space
        paragStyle.alignment = self.textAlignment
        attribStr.addAttributes([NSAttributedString.Key.paragraphStyle: paragStyle], range: NSMakeRange(0, attribStr.length))
        self.attributedText = attribStr
    }
    
    func textBGColor(_ fullText : String , changeText : String ) {
        
        let strNumber: NSString = fullText as NSString
        
        let paragStyle = NSMutableParagraphStyle()
        paragStyle.lineSpacing = 4
        paragStyle.alignment = self.textAlignment
        
        let attribute = NSMutableAttributedString(string: fullText, attributes: [.backgroundColor: UIColor.clear, .paragraphStyle: paragStyle])
        
        if changeText.count > 0 {
            let strarr = changeText.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            strarr.forEach { (str) in
                let range = (strNumber).range(of: str, options: .caseInsensitive)
                attribute.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: range)
            }
        }
        self.attributedText = attribute
    }
    
//    @IBInspectable
    var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }
            
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            
            attributedText = attributedString
        }
        
        get {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}


// MARK: -
// MARK: -  Circle View
class CircleView : UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let rad = min(bounds.width, bounds.height)/2
        self.cornerRadius = rad
    }
}


class CircleImageView : UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let rad = min(bounds.width, bounds.height)/2
        self.cornerRadius = rad
    }
}

class CircleButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let rad = min(bounds.width, bounds.height)/2
        self.cornerRadius = rad
    }
}

class CircleTextField : UITextField {
    override func layoutSubviews() {
        super.layoutSubviews()
        let rad = min(bounds.width, bounds.height)/2
        self.cornerRadius = rad
    }
}


// MARK: -
// MARK: -  UIImageView
extension UIImageView {
    
    @IBInspectable var templateImage: Bool {
        get {
            return false
        }
        set(value){
            if let img = image, value {
                let img1 = img.withRenderingMode(.alwaysTemplate)
                self.image = img1
            }
        }
    }
}

extension UIButton {
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel?.font =  UIFont(name: self.titleLabel?.font.fontName ?? "SofiaPro-SemiBold", size: setCustomFont(self.titleLabel?.font.pointSize ?? 17))
        
    }
    
//        @IBInspectable var localizeKey: String {
//        get {
//            return ""
//        } set {
//            self.setTitle(MyLocalized.setLocalize(newValue), for: .normal)
//        }
//    }

//    @IBInspectable var templateImage: Bool {
//        get {
//            return false
//        }
//        set(value){
//            if let img = currentImage, value {
//                let img1 = img.withRenderingMode(.alwaysTemplate)
//                self.setImage(img1, for: self.state)
//            }
//        }
//    }
    
    func alignVertical(spacing: CGFloat = 6.0) {
        guard let imageSize = imageView?.image?.size,
            let text = titleLabel?.text,
            let font = titleLabel?.font
            else { return }
        
        titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageSize.width,
            bottom: -(imageSize.height + spacing),
            right: 0.0
        )
        
        let titleSize = text.size(withAttributes: [.font: font])
        imageEdgeInsets = UIEdgeInsets(
            top: -(titleSize.height + spacing),
            left: 0.0,
            bottom: 0.0, right: -titleSize.width
        )
        
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
        contentEdgeInsets = UIEdgeInsets(
            top: edgeOffset,
            left: 0.0,
            bottom: edgeOffset,
            right: 0.0
        )
    }
    
    public func setUnderlineButton() {
        let text = self.titleLabel?.text
        let titleString = NSMutableAttributedString(string: text!)
        titleString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSMakeRange(0, (text?.count)!))
        self.setAttributedTitle(titleString, for: .normal)
    }
}


// MARK: -
// MARK: -  UIImage
extension UIImage {
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage {
        
        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero
        
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = 0
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContext(scaledImageRect.size)
        
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    

    public func tintWithColor(_ color: UIColor) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
            //UIGraphicsBeginImageContext(self.size)
            let context = UIGraphicsGetCurrentContext()
            // flip the image
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.translateBy(x: 0.0, y: -self.size.height)
            // multiply blend mode
            context?.setBlendMode(.multiply)
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            context?.clip(to: rect, mask: self.cgImage!)
            color.setFill()
            context?.fill(rect)
            // create uiimage
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
    
}

extension CGFloat {
    
    var dp: CGFloat {
        return (self / 320) * UIScreen.main.bounds.width
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let str = label.attributedText!
        let attr = NSMutableAttributedString(attributedString: str)
        attr.addAttributes([NSAttributedString.Key.font: label.font!], range: NSRange(location: 0, length: str.length))
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attr)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.frame.size
        textContainer.size = CGSize(width: labelSize.width, height: CGFloat.greatestFiniteMagnitude)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let locationOfTouchInLabel = self.location(in: label)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInLabel, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}



// ====================================================================================

// get ratio screen
struct RATIO {
    static let SCREEN_WIDTH               = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.WIDTH / 375.0)
    static let SCREEN_HEIGHT              = (DeviceType.IPHONE_4_OR_LESS ? 1.0 : Screen.HEIGHT / 667.0)
    static let SCREEN                     = ((RATIO.SCREEN_WIDTH + RATIO.SCREEN_HEIGHT) / 2)
}


// get screen size
struct Screen {
    static let BOUNDS   = UIScreen.main.bounds
    static let WIDTH    = UIScreen.main.bounds.size.width
    static let HEIGHT   = UIScreen.main.bounds.size.height
    static let MAX      = max(Screen.WIDTH, Screen.HEIGHT)
    static let MIN      = min(Screen.WIDTH, Screen.HEIGHT)
    static let HEIGHTNATIVE = UIScreen.main.nativeBounds.height
    
}

// get device type
struct DeviceType {
    static let IPHONE_4_OR_LESS        = UIDevice.current.userInterfaceIdiom == .phone && Screen.HEIGHTNATIVE <  1136
    static let IPHONE_5_5S_5C          = UIDevice.current.userInterfaceIdiom == .phone && Screen.HEIGHTNATIVE == 1136
    static let IPHONE_6_6S_7_8         = UIDevice.current.userInterfaceIdiom == .phone && Screen.HEIGHTNATIVE == 1334
    static let IPHONE_6P_6SP_7P_8P     = UIDevice.current.userInterfaceIdiom == .phone && Screen.HEIGHTNATIVE == 1920
    static let IPAD                    = UIDevice.current.userInterfaceIdiom == .pad   && Screen.HEIGHTNATIVE >= 2048
    static let IPHONE_X                = UIDevice.current.userInterfaceIdiom == .phone && Screen.HEIGHTNATIVE == 2436
}


extension Optional where Wrapped: UIImage {
    
    func isEqualToImage(_ image: UIImage?) -> Bool {
        
        if self == nil {
            return false
        }
        if image == nil {
            return false
        }
        
        if let selfData = self!.jpegData(compressionQuality: 1.0), let otherData = image!.jpegData(compressionQuality: 1.0) {
            return selfData == otherData
        }
        return false
    }
}


extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
}


extension Date {
    
    static func getDates(forLastNDays nDays: Int) -> [String] {
        let cal = NSCalendar.current
        // start with today
        var date = cal.startOfDay(for: Date())
        
        var arrDates = [String]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d,yyyy"
        let dateString = dateFormatter.string(from: date)
        arrDates.append(dateString)
        
        for _ in 1 ... nDays {
            // move back in time by one day:
            date = cal.date(byAdding: Calendar.Component.day, value: -1, to: date)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d,yyyy"
            let dateString = dateFormatter.string(from: date)
            arrDates.append(dateString)
        }
        print(arrDates)
        return arrDates
    }
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Int {
    
    var ordinal: String {
        var suffix: String
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        if tens == 1 {
            suffix = "th"
        } else if ones == 1 {
            suffix = "st"
        } else if ones == 2 {
            suffix = "nd"
        } else if ones == 3 {
            suffix = "rd"
        } else {
            suffix = "th"
        }
        return "\(self)\(suffix)"
    }
    
    func secondsToTime() -> String {
        
        let (h,m,s) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
        
        let h_string = h < 10 ? "0\(h)" : "\(h)"
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"
        
        return "\(h_string):\(m_string):\(s_string)"
    }
}


extension UIColor {
    
    static func getGradientColor(_ colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint , frame : CGRect) -> UIColor?{
        
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = frame
        
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        
        //Set out gradient's colors
        gradientlayer.colors = cgColors
        
        //Specify the direction our gradient will take
        gradientlayer.startPoint = startPoint
        gradientlayer.endPoint = endPoint
        
        return getColorFromLayer(gradientlayer)
    }
    
    
    static func getColorFromLayer(_ gradientlayer: CAGradientLayer) -> UIColor? {
        
        UIGraphicsBeginImageContextWithOptions(gradientlayer.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            gradientlayer.render(in: context)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if img == nil {
                return nil
            }
            return UIColor(patternImage: img!)
        }
        return nil
    }
    
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}


extension UIImageView {
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
    }
    
    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}

func getimageWithNewSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
    
}


func closeXIB(XIB : UIView){
    
    UIView.animate(withDuration: 0.25, animations: {
        XIB.transform = CGAffineTransform(translationX: 0, y: UIScreen.height)
    }) { (done) in
        
        XIB.isHidden = true
    }
}

func openXIB(XIB : UIView) {
    
    XIB.isHidden = false
    XIB.frame = UIScreen.main.bounds
    XIB.transform = CGAffineTransform(translationX: 0, y: UIScreen.height)

    UIView.animate(withDuration: 0.25) {
       XIB.transform = CGAffineTransform.identity
        
    }
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

@IBDesignable
class CustomSlider : UISlider {
    @IBInspectable open var trackHeight:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackHeight/2,
            width: defaultBounds.size.width,
            height: trackHeight
        )
    }
    
    let label = UILabel()
    let imageView = UIImageView()
    
    @IBInspectable var image: UIImage? { didSet {  imageView.image = self.image } }
    @IBInspectable var iContentMode: UIImageView.ContentMode = .scaleAspectFit { didSet {  } }
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let track = super.beginTracking(touch, with: event)
        
        imageView.frame = CGRect.init(x: self.thumbCenterX - 15, y: -30, width: 30, height: 30)
        //        imageView.image = UIImage(named: "pin")
        
        label.text = "\(Int(self.value))"
        label.textAlignment = .center
        label.frame = CGRect.init(x: self.thumbCenterX - 15, y: -25, width: 30, height: 20)
        label.font = UIFont(name: "Gilroy-Regular", size: 12)
        self.addSubview(imageView)
        self.addSubview(label)
        return track
    }
    
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let track = super.continueTracking(touch, with: event)
        
        imageView.frame = CGRect.init(x: self.thumbCenterX - 15, y: -30, width: 30, height: 30)
        
        label.textAlignment = .center
        label.frame = CGRect.init(x: self.thumbCenterX - 15, y: -25, width: 30, height: 20)
        label.font = UIFont(name: AppFont.RoobertRegular, size: 12)
        
        label.text = "\(Int(self.value))"
        return track
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
    }
}
                
extension UISlider {                                                                                
    var thumbCenterX: CGFloat {
        _ = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: bounds, value: value)
        return thumbRect.midX
    }
}

public enum MediaType {
    case photo,video
}

enum PickerType {
    case photoLibrary,videoPhotoLibrary,cameraVideo,cameraPhoto
}

extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let x = (UIScreen.Width - (message.widthOfString(usingFont: font) + 20)) / 2
        let toastLabel = UILabel(frame: CGRect(x: x, y: self.view.frame.size.height-100, width: message.widthOfString(usingFont: font) + 20, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 7.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { (isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func openPhotoSelectionOption(for imagePicker:UIImagePickerController, type : MediaType) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if type == .photo {
                self.openUIImagePickerController(for: imagePicker, type: .cameraPhoto)
            } else if type == .video {
                self.openUIImagePickerController(for: imagePicker, type: .cameraVideo)
            }
        }
        
        let galeryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            if type == .photo {
                self.openUIImagePickerController(for: imagePicker, type: .photoLibrary)
            } else if type == .video {
                self.openUIImagePickerController(for: imagePicker, type: .videoPhotoLibrary)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galeryAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openUIImagePickerController(for imagePicker:UIImagePickerController, type : PickerType) {
        
        if type == .photoLibrary {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
            } else {
                print("photoLibrary not available")
            }
        } else if type == .cameraPhoto {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.cameraCaptureMode = .photo
            } else {
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        } else if type == .videoPhotoLibrary {
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                
            }else{
                print("photoLibrary not available")
            }
        } else if type == .cameraVideo {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.cameraCaptureMode = .video
            } else {
                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

//@IBDesignable
class GradientShadowView: UIView {
    
    @IBInspectable var gradient: Bool = false {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropStartColor: UIColor = .white {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropEndColor: UIColor = .gray {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropStartPoint: CGPoint = .zero {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropEndPoint: CGPoint = CGPoint(x: 1.0, y: 1.0) {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropCornerRadius: CGFloat = 5.0 {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowColor: UIColor = UIColor("000000") {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowRadius: CGFloat = 3.0 {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowOpacity: Float = 0.18 {
        didSet {
            self.updateProperties()
        }
    }
    
    private var _backgroundcolor: UIColor?
    override var backgroundColor: UIColor? {
        get {
            return _backgroundcolor
        }
        set(color) {
            _backgroundcolor = color
            super.backgroundColor = color
        }
    }
    
    /**
     Masks the layer to it's bounds and updates the layer properties and shadow path.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = false
        
        updateProperties()
        updateShadowPath()
    }
    
    /**
     Updates all layer properties according to the public properties of the `ShadowView`.
     */
    fileprivate func updateProperties() {
        self.layer.cornerRadius = self.dropCornerRadius
        self.layer.shadowColor = self.dropShadowColor.cgColor
        self.layer.shadowOffset = self.dropShadowOffset
        self.layer.shadowRadius = self.dropShadowRadius
        self.layer.shadowOpacity = self.dropShadowOpacity
        
        updateGradient()
    }
    
    
    fileprivate func updateGradient() {
        if gradient {
            self.backgroundColor = getGradientColor([dropStartColor, dropEndColor], startPoint: dropStartPoint, endPoint: dropEndPoint)
        }
        else {
            self.backgroundColor = _backgroundcolor
        }
    }
    
    /**
     Updates the bezier path of the shadow to be the same as the layer's bounds, taking the layer's corner radius into account.
     */
    fileprivate func updateShadowPath() {
        self.layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    /**
     Updates the shadow path everytime the views frame changes.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateShadowPath()
        updateGradient()
    }
    
    func getGradientColor(_ colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIColor? {
        
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = self.bounds
        
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        
        //Set out gradient's colors
        gradientlayer.colors = cgColors
        
        //Specify the direction our gradient will take
        gradientlayer.startPoint = startPoint
        gradientlayer.endPoint = endPoint
        
        return getColorFromLayer(gradientlayer)
    }
    
    
    func getColorFromLayer(_ gradientlayer: CAGradientLayer) -> UIColor? {
        
        UIGraphicsBeginImageContextWithOptions(gradientlayer.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            gradientlayer.render(in: context)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if img == nil {
                return nil
            }
            return UIColor(patternImage: img!)
        }
        return _backgroundcolor
    }
}



//@IBDesignable
class GradientShadowButton: UIButton {
    
    @IBInspectable var gradient: Bool = false {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropStartColor: UIColor = .white {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropEndColor: UIColor = .gray {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropStartPoint: CGPoint = .zero {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropEndPoint: CGPoint = CGPoint(x: 1.0, y: 1.0) {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropCornerRadius: CGFloat = 5.0 {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowColor: UIColor = UIColor("000000") {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowOffset: CGSize = CGSize(width: 0.0, height: 0.0) {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowRadius: CGFloat = 3.0 {
        didSet {
            self.updateProperties()
        }
    }
    
    @IBInspectable var dropShadowOpacity: Float = 0.18 {
        didSet {
            self.updateProperties()
        }
    }
    
    private var _backgroundcolor: UIColor?
    override var backgroundColor: UIColor? {
        get {
            return _backgroundcolor
        }
        set(color) {
            _backgroundcolor = color
            super.backgroundColor = color
        }
    }
    
    /**
     Masks the layer to it's bounds and updates the layer properties and shadow path.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = false
        
        updateProperties()
        updateShadowPath()
    }
    
    /**
     Updates all layer properties according to the public properties of the `ShadowView`.
     */
    fileprivate func updateProperties() {
        self.layer.cornerRadius = self.dropCornerRadius
        self.layer.shadowColor = self.dropShadowColor.cgColor
        self.layer.shadowOffset = self.dropShadowOffset
        self.layer.shadowRadius = self.dropShadowRadius
        self.layer.shadowOpacity = self.dropShadowOpacity
        
        updateGradient()
    }
    
    
    fileprivate func updateGradient() {
        if gradient {
            self.backgroundColor = getGradientColor([dropStartColor, dropEndColor], startPoint: dropStartPoint, endPoint: dropEndPoint)
        }
        else {
            self.backgroundColor = _backgroundcolor
        }
    }
    
    /**
     Updates the bezier path of the shadow to be the same as the layer's bounds, taking the layer's corner radius into account.
     */
    fileprivate func updateShadowPath() {
        self.layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    /**
     Updates the shadow path everytime the views frame changes.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateShadowPath()
        updateGradient()
    }
    
    func getGradientColor(_ colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIColor? {
        
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = self.bounds
        
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        
        //Set out gradient's colors
        gradientlayer.colors = cgColors
        
        //Specify the direction our gradient will take
        gradientlayer.startPoint = startPoint
        gradientlayer.endPoint = endPoint
        
        return getColorFromLayer(gradientlayer)
    }
    
    
    func getColorFromLayer(_ gradientlayer: CAGradientLayer) -> UIColor? {
        
        UIGraphicsBeginImageContextWithOptions(gradientlayer.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            gradientlayer.render(in: context)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if img == nil {
                return nil
            }
            return UIColor(patternImage: img!)
        }
        return _backgroundcolor
    }
}

@IBDesignable class ShadowImageView: UIView {
    
    @IBInspectable var dropBorderColor: UIColor = .black { didSet { self.layer.borderColor = self.dropBorderColor.cgColor } }
    @IBInspectable var dropBorderWidth: CGFloat = 0.00 { didSet { self.layer.borderWidth = self.dropBorderWidth } }
    @IBInspectable var dropCornerRadius: CGFloat = 0.00 {
        didSet {
            self.layer.cornerRadius = self.dropCornerRadius
            layoutImage()
        }
    }
    
    // ImageView Attributes
    @IBInspectable var image: UIImage? { didSet {  layoutImage() } }
    @IBInspectable var iContentMode: UIView.ContentMode = .scaleAspectFit { didSet { layoutImage() } }
    
    // Shadow Attributes
    @IBInspectable var imageShadowColor: UIColor = .black { didSet { dropShadow() } }
    @IBInspectable var imageShadowOpacity: Float = 0.0 { didSet { dropShadow() } }
    @IBInspectable var imageShadowRadius: CGFloat = 0.0 { didSet { dropShadow() } }
    @IBInspectable var imageShadowOffset: CGSize = .zero { didSet { dropShadow() } }
    
    var imageView = UIImageView()
    //    var shadowView = UIView()
    
    override func layoutSubviews() {
        layoutImage()
        dropShadow()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView() {
        self.layer.cornerRadius = dropCornerRadius
        self.layer.borderWidth = dropBorderWidth
        self.layer.borderColor = dropBorderColor.cgColor
    }
    
    fileprivate func layoutImage() {
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.bounds.height)
        
        //        let width = self.bounds.width/1.2
        //        let height = self.bounds.height/2
        //        let x = (self.bounds.width - width)/2
        //        shadowView.frame = CGRect(x: x, y: height, width: width, height: height)
        
        for v in self.subviews {
            v.removeFromSuperview()
        }
        //        self.addSubview(shadowView)
        self.addSubview(imageView)
        imageView.image = self.image
        imageView.contentMode = self.contentMode
        imageView.layer.cornerRadius = self.layer.cornerRadius
        imageView.layer.masksToBounds = true
    }
    
    fileprivate func dropShadow() {
        self.layer.shadowColor = imageShadowColor.cgColor
        self.layer.shadowOpacity = imageShadowOpacity
        self.layer.shadowOffset = imageShadowOffset
        self.layer.shadowRadius = imageShadowRadius
        self.layer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: cornerRadius).cgPath
    }
}



@IBDesignable class MaskImageView: UIImageView {
    var maskImageView = UIImageView()
    
    @IBInspectable
    var maskImage: UIImage? {
        didSet {
            maskImageView.image = maskImage
            updateView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    func updateView() {
        if maskImageView.image != nil {
            maskImageView.frame = bounds
            mask = maskImageView
        }
    }
}

//@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var gradient: Bool = false {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropStartColor: UIColor = .white {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropEndColor: UIColor = .gray {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropStartPoint: CGPoint = .zero {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropEndPoint: CGPoint = CGPoint(x: 1.0, y: 1.0) {
        didSet {
            self.updateGradient()
        }
    }
    
    
    private var _backgroundcolor: UIColor?
    override var backgroundColor: UIColor? {
        get {
            return _backgroundcolor
        }
        set(color) {
            _backgroundcolor = color
            super.backgroundColor = color
        }
    }
    
    /**
     Masks the layer to it's bounds and updates the layer properties and shadow path.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateGradient()
    }
    
    
    fileprivate func updateGradient() {
        if gradient {
            self.backgroundColor = getGradientColor([dropStartColor, dropEndColor], startPoint: dropStartPoint, endPoint: dropEndPoint)
        }
        else {
            self.backgroundColor = _backgroundcolor
        }
    }
    
    /**
     Updates the shadow path everytime the views frame changes.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateGradient()
    }
    
    func getGradientColor(_ colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIColor? {
        
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = self.bounds
        
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        
        //Set out gradient's colors
        gradientlayer.colors = cgColors
        
        //Specify the direction our gradient will take
        gradientlayer.startPoint = startPoint
        gradientlayer.endPoint = endPoint
        
        return getColorFromLayer(gradientlayer)
    }
    
    
    func getColorFromLayer(_ gradientlayer: CAGradientLayer) -> UIColor? {
        
        UIGraphicsBeginImageContextWithOptions(gradientlayer.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            gradientlayer.render(in: context)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if img == nil {
                return nil
            }
            return UIColor(patternImage: img!)
        }
        return _backgroundcolor
    }
}


//@IBDesignable
class GradientButton: UIButton {
    
    @IBInspectable var gradient: Bool = false {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropStartColor: UIColor = .white {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropEndColor: UIColor = .gray {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropStartPoint: CGPoint = .zero {
        didSet {
            self.updateGradient()
        }
    }
    
    @IBInspectable var dropEndPoint: CGPoint = CGPoint(x: 1.0, y: 1.0) {
        didSet {
            self.updateGradient()
        }
    }
    
    
    private var _backgroundcolor: UIColor?
    override var backgroundColor: UIColor? {
        get {
            return _backgroundcolor
        }
        set(color) {
            _backgroundcolor = color
            super.backgroundColor = color
        }
    }
    
    /**
     Masks the layer to it's bounds and updates the layer properties and shadow path.
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateGradient()
    }
    
    
    fileprivate func updateGradient() {
        if gradient {
            self.backgroundColor = getGradientColor([dropStartColor, dropEndColor], startPoint: dropStartPoint, endPoint: dropEndPoint)
        }
        else {
            self.backgroundColor = _backgroundcolor
        }
    }
    
    /**
     Updates the shadow path everytime the views frame changes.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateGradient()
    }
    
    func getGradientColor(_ colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIColor? {
        
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = self.bounds
        
        var cgColors = [CGColor]()
        for color in colors {
            cgColors.append(color.cgColor)
        }
        
        //Set out gradient's colors
        gradientlayer.colors = cgColors
        
        //Specify the direction our gradient will take
        gradientlayer.startPoint = startPoint
        gradientlayer.endPoint = endPoint
        
        return getColorFromLayer(gradientlayer)
    }
    
    
    func getColorFromLayer(_ gradientlayer: CAGradientLayer) -> UIColor? {
        
        UIGraphicsBeginImageContextWithOptions(gradientlayer.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            gradientlayer.render(in: context)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if img == nil {
                return nil
            }
            return UIColor(patternImage: img!)
        }
        return _backgroundcolor
    }
}

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

class LoadingButton: UIButton {
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView!
    
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        self.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}

func setMsgWithSVProgress(_ msg: String) {
    SVProgressHUD.setBackgroundColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    SVProgressHUD.setMaximumDismissTimeInterval(1.0)
    SVProgressHUD.showSuccess(withStatus: msg)
}

func setErrorMsgWithSVProgress(_ msg: String) {
    SVProgressHUD.setBackgroundColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    SVProgressHUD.setMaximumDismissTimeInterval(1.0)
    SVProgressHUD.showError(withStatus: msg)
}

extension UITextView : UITextViewDelegate {
    
    func setLineIncrease(_ minimumHeight : CGFloat) {
        
        self.delegate = self
        
        NotificationCenter.default.addObserver(
               self, selector: #selector(self.textViewDidValueChange(notification:)),
               name: UITextView.textDidChangeNotification, object: self)
        setHeight(minimumHeight)
    }
    
    @objc func textViewDidValueChange(notification: Notification) {
        var height : CGFloat = 70.0
        if let temHeight = notification.object as? UITextView {
            height = temHeight.frame.height
        }
        setHeight(height)
    }
    
    func setHeight(_ minimumHeight : CGFloat) {
        
        self.updateWithSpacing(lineSpacing: 5)
        self.layoutIfNeeded()
        
        setAfter {
            self.translatesAutoresizingMaskIntoConstraints = false
            if let height = self.constraintWithIdentifier("Height") {
                if self.contentSize.height < UIScreen.height / 2 {
                    height.constant = max(self.contentSize.height, minimumHeight)
                    height.isActive = true
                    self.layer.cornerRadius = self.contentSize.height < 40 ? self.contentSize.height / 4 : 10
                    self.layoutIfNeeded()
                }
               
            }
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.updateWithSpacing(lineSpacing: 5)
        return true
    }
   
}

extension Date {

    func dateFormatWithSuffix() -> String {
        let selectedFormatter = DateFormatter()
        selectedFormatter.dateFormat = "EEEE"
        
        let day = selectedFormatter.string(from: self)
        selectedFormatter.dateFormat = "d"
        let date = selectedFormatter.string(from: self)
        selectedFormatter.dateFormat = "MMM"
        let month = selectedFormatter.string(from: self)
        
        return "\(day), \(date)\(self.daySuffix()) \(month)"
    }

    func daySuffix() -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

func setCustomFont(_ fontSize : CGFloat) -> CGFloat {
    
    let bounds = UIScreen.main.bounds
    let width = bounds.size.width
    
    let baseWidth: CGFloat = 360
    
    let fontSize = fontSize * (width / baseWidth)
    
    return fontSize
}

func getDocumentDirectory() -> URL {
    let fileManager = FileManager.default
    if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let filePath = documentDirectory
        if !fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Couldn't create document directory")
            }
        }
        return filePath
    }
    return URL(fileURLWithPath: NSTemporaryDirectory())
}
