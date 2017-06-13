//
//  BananaViewController.swift
//  SwiftMonkeyExample
//
//  Created by Dag Agren on 07/11/2016.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

class BananaViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var banana: UILabel?

    var offset: CGPoint = CGPoint.zero
    var scale: CGFloat = 1
    var angle: CGFloat = 0

    var maxOffset: CGPoint {
        return CGPoint(
            x: (view.frame.size.width - (banana?.frame.size.width ?? 0)) / 2,
            y: (view.frame.size.height - (banana?.frame.size.height ?? 0)) / 2
        )
    }

    var maxYOffset: CGFloat {
        return (view.frame.size.height - (banana?.frame.size.height ?? 0)) / 2
    }

    let maxScale: CGFloat = 2
    let minScale: CGFloat = 1 / 2

    var currentTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: scale, y: scale).concatenating(
        CGAffineTransform(rotationAngle: angle)).concatenating(
        CGAffineTransform(translationX: offset.x, y: offset.y))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func gestureRecognizer(_ recognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    var startOffset: CGPoint = CGPoint.zero
    @IBAction func panned(recogniser: UIPanGestureRecognizer) {
        if recogniser.state == .began {
            startOffset = offset
        } else {
            let translation = recogniser.translation(in: view)
            offset.x = startOffset.x + translation.x
            offset.y = startOffset.y + translation.y

            let max = maxOffset
            if offset.x > max.x { offset.x = max.x }
            if offset.y > max.y { offset.y = max.y }
            if offset.x < -max.x { offset.x = -max.x }
            if offset.y < -max.y { offset.y = -max.y }

            banana?.transform = currentTransform
        }
    }

    var startScale: CGFloat = 1
    @IBAction func pinched(recogniser: UIPinchGestureRecognizer) {
        if recogniser.state == .began {
            startScale = scale
        } else {
            scale = startScale * recogniser.scale
            if scale > maxScale { scale = maxScale }
            if scale < minScale { scale = minScale }
            banana?.transform = currentTransform
        }
    }

    var startAngle: CGFloat = 0
    @IBAction func rotated(recogniser: UIRotationGestureRecognizer) {
        if recogniser.state == .began {
            startAngle = angle
        } else {
            angle = startAngle + recogniser.rotation
            banana?.transform = currentTransform
        }
    }

    @IBAction func bananaTapped(recogniser: UITapGestureRecognizer) {
        guard let banana = banana else { return }
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [ .allowUserInteraction ], animations: {
            let steps = 24
            for i in 0 ..< steps {
                let frameLength = 1 / Double(steps)
                let startTime = Double(i) * frameLength
                let endTime = Double(i + 1) * frameLength
                let curve = (1 - cos(2 * Double.pi * endTime * 3)) / 2 * exp(-endTime * 5)
                let scale = CGFloat(1 + 0.5 * curve)
                UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: frameLength, animations: {
                    banana.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(self.currentTransform)
                })
            }
        }, completion: nil)
    }
}

