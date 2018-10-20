//
//  UIViewControllerExtension.swift
//
//

import Foundation
import UIKit


extension UIViewController: NVActivityIndicatorViewable {

    //MARK: - LOADER
    func showLoader(_ show: Bool, message : String? = nil, color : UIColor? = #colorLiteral(red: 0.04705882353, green: 0.3254901961, blue: 0.6156862745, alpha: 1), backgroundColor : UIColor? = nil, textColor : UIColor? = nil) {
        DispatchQueue.main.async {
            
//            let loaders : [NVActivityIndicatorType] = [.ballPulse, .ballGridPulse, .ballClipRotate, .squareSpin, .ballClipRotatePulse, .ballClipRotateMultiple, .ballPulseRise, .ballRotate, .cubeTransition, .ballZigZag, .ballZigZagDeflect, .ballTrianglePath, .ballScale, .lineScale, .lineScaleParty, .ballScaleMultiple, .ballPulseSync, .ballBeat, .lineScalePulseOut, .lineScalePulseOutRapid, .ballScaleRipple, .ballScaleRippleMultiple, .ballSpinFadeLoader, .lineSpinFadeLoader, .triangleSkewSpin, .pacman, .ballGridBeat, .semiCircleSpin, .ballRotateChase, .orbit, .audioEqualizer, .circleStrokeSpin]
            
            if show {
                self.startAnimating(CGSize(width: 150, height: 150), message: message, messageFont: nil, type: .ballScaleMultiple
, color:  #colorLiteral(red: 0.04705882353, green: 0.3254901961, blue: 0.6156862745, alpha: 1), backgroundColor: backgroundColor, textColor: textColor)
                
//                self.startAnimating(CGSize(width: 150, height: 150), message: message, messageFont: nil, type: loaders.randomElement(), color:  #colorLiteral(red: 0.04705882353, green: 0.3254901961, blue: 0.6156862745, alpha: 1), backgroundColor: backgroundColor, textColor: textColor)
                
            } else {
                self.stopAnimating()
            }
        }
    }
    
    //MARK: - ALERT & LOADER OFF
    func connectionError() {
        DispatchQueue.main.async {
            self.showLoader(false)
//            self.creatErrorAlert()
            self.showAlert(message: "Ocurrió un error de conexión, vuelva a intentar más tarde")
        }
    }
    
    //MARK: - ALERT
    func showAlert(title: String = "Information", message: String, btnTitle: String = "Ok", btnStyle: UIAlertAction.Style = UIAlertAction.Style.default ,btnHandler: ((UIAlertAction)->Void)? = nil, action2: UIAlertAction? = nil) {
        let alertC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: btnTitle, style: btnStyle, handler: btnHandler)
        alertC.addAction(action1)
        
        if action2 != nil {
            alertC.addAction(action2!)
        }
        
        self.present(alertC, animated: true, completion: nil)
    }
}
