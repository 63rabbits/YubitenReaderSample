//
//  ViewController.swift
//  YubitenReaderSample
//
//  Created by 63rabbits goodman on 2024/03/01.
//

import UIKit
import YubitenReader

class ViewController: UIViewController {

    let fontSize = CGFloat(80)
    var brailleLabel = UILabel()
    var yubitenReader: YubitenReader!

    override func viewDidLoad() {
        super.viewDidLoad()

        // YubitenReader
        yubitenReader = YubitenReader(frame: self.view.frame, handler: brailleReader)
        yubitenReader.showGuide = true
//        setupGguide()
//        setupTouchSpot()
//        setupSwipe()
        setupVibration()
        setupGuideSpot()
        self.view.addSubview(yubitenReader)

        // Braille label
        setupBrailleLabel()
        view.bringSubviewToFront(brailleLabel)

        print("start!!")
    }



    // MARK: - Setup

    func setupGguide() {
        yubitenReader.titleLabel.text = "\u{283f} Hello World"
        yubitenReader.backgroundColor = UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.5)

        yubitenReader.showGuide = true

        yubitenReader.middleFingerWidth = 100
        yubitenReader.fingerAngle = 1.0  // radian
        yubitenReader.fingerBias = CGPoint(x: -50, y: 0)
        yubitenReader.labelColor = UIColor.red
        yubitenReader.indexFingerColor = UIColor.red.withAlphaComponent(0.5)
        yubitenReader.middleFingerColor = UIColor.green.withAlphaComponent(0.5)
        yubitenReader.ringFingerColor = UIColor.blue.withAlphaComponent(0.5)
        yubitenReader.borderWidth = 5
        yubitenReader.borderColor = UIColor.green.withAlphaComponent(0.5)
    }

    func setupTouchSpot() {
//        yubitenReader.showTouchSpot = false
        yubitenReader.touchSpotSize = 80
        yubitenReader.touchSpotColor = UIColor.blue.withAlphaComponent(0.5)
    }

    func setupSwipe() {
        yubitenReader.swipeDistance = 50
    }

    func setupVibration() {
//        yubitenReader.vibration = true
        yubitenReader.vibrationBraille = [ "\u{2802}", "\u{2810}" ]     // ②,⑤
        yubitenReader.vibrationInterval = 0.2
        yubitenReader.vibrationSound = true
        yubitenReader.vibrationSoundID = 1057
    }

    func setupGuideSpot() {
//        yubitenReader.guideSpot = true
        yubitenReader.guideSpotBraille = "\u{2812}"
        yubitenReader.guideSpotSize = 70
        yubitenReader.guideSpotColor = UIColor.black.withAlphaComponent(0.5)
    }

    func setupBrailleLabel() {
        brailleLabel.setText(message: " \u{283f}", fontsize: fontSize, color: UIColor.gray)
        brailleLabel.backgroundColor = UIColor.white
        brailleLabel.layer.cornerRadius = brailleLabel.bounds.width / 5.0
        brailleLabel.clipsToBounds = true
        brailleLabel.numberOfLines = 4
        view.addSubview(brailleLabel)
        // auto layout : center the label
        brailleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            brailleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            brailleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
        ])
    }



    // MARK: - Read Braille

    func brailleReader(reco: YubitenReader.Recognition, braille: String, swipes: [YubitenReader.SwipeType]) {
        switch reco {
            case .braille:
                self.brailleLabel.setText(message: " " + braille, fontsize: self.fontSize, color: UIColor.black)
//                print(braille)

            case .swipe:
                var stringArray: [String] = []
                for swipe in swipes { stringArray.append(swipe.rawValue) }
                let msg = stringArray.joined(separator: "\n")
                self.brailleLabel.setText(message: msg, fontsize: 30, color: UIColor.black)
//                print(msg.replacingOccurrences(of: "\n", with: ", "))

                // Vibration
                if swipes.contains(.swipeLeft1) && swipes.contains(.swipeRight1) {
                    yubitenReader.vibration = !yubitenReader.vibration
                    yubitenReader.guideSpot = yubitenReader.vibration
                }

                // Lock Screen
                else if swipes.contains(.swipeUp2) && swipes.contains(.swipeDown2) {
                    yubitenReader.unlockIfOrientation()
                }
                else if swipes.contains(.swipeLeft2) && swipes.contains(.swipeRight2) {
                    yubitenReader.unlockIfOrientation()
                }
                else if swipes.contains(.swipeUp2)      { lockIfOrientation(direction: .down) }
                else if swipes.contains(.swipeDown2)    { lockIfOrientation(direction: .up) }
                else if swipes.contains(.swipeLeft2)    { lockIfOrientation(direction: .right) }
                else if swipes.contains(.swipeRight2)   { lockIfOrientation(direction: .left) }
                else if swipes.contains(.swipeUp4)      { lockIfOrientation(direction: .down, isFlat: true) }
                else if swipes.contains(.swipeDown4)    { lockIfOrientation(direction: .up, isFlat: true) }
                else if swipes.contains(.swipeLeft4)    { lockIfOrientation(direction: .right, isFlat: true) }
                else if swipes.contains(.swipeRight4)   { lockIfOrientation(direction: .left, isFlat: true) }



                // for debug on simulator
//                else if swipes.contains(.swipeUp1) && swipes.contains(.swipeDown1) {
//                    yubitenReader.unlockIfOrientation()
//                }
//                else if swipes.contains(.swipeUp1)      { lockIfOrientation(direction: .down) }
//                else if swipes.contains(.swipeDown1)    { lockIfOrientation(direction: .up) }
//                else if swipes.contains(.swipeLeft1)    { lockIfOrientation(direction: .right) }
//                else if swipes.contains(.swipeRight1)   { lockIfOrientation(direction: .left) }
//                else if swipes.contains(.swipeUp2)      { lockIfOrientation(direction: .down, isFlat: true) }
//                else if swipes.contains(.swipeDown2)    { lockIfOrientation(direction: .up, isFlat: true) }
//                else if swipes.contains(.swipeLeft2)    { lockIfOrientation(direction: .right, isFlat: true) }
//                else if swipes.contains(.swipeRight2)   { lockIfOrientation(direction: .left, isFlat: true) }

            case .failure:
                self.brailleLabel.setText(message: " ? ", fontsize: self.fontSize, color: UIColor.black)
//                print("?")
        }
    }

    enum Direction: Int {
        case up     = 0
        case right  = 1
        case down   = 2
        case left   = 3
    }
    func lockIfOrientation(direction: Direction, isFlat: Bool = false) {
        let dir = determineNewIfOrientation(direction: direction)
        if isFlat && dir != .landscapeLeft && dir != .landscapeRight { return }
        yubitenReader.lockIfOrientation(dir, isFlat: isFlat)
    }

    func determineNewIfOrientation(direction: Direction) -> UIInterfaceOrientation {
        let orientation: [UIInterfaceOrientation] = [ .portrait, .landscapeRight, .portraitUpsideDown, .landscapeLeft ]
        let current = yubitenReader.ifOrientation!
        var index = orientation.firstIndex(of: current)!
        index = (index + direction.rawValue) % orientation.count
        return orientation[index]
    }



    // MARK: - REQUIRED

    // Add the following method to ensure screen lock.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return yubitenReader?.supportedIfOrientations ?? .all
    }

}



extension UILabel {

    func setText(message: String, fontsize: CGFloat, color: UIColor) {
        self.text = message
        self.font = UIFont.systemFont(ofSize: fontsize)
        self.textColor = color
        self.sizeToFit()
    }

}
