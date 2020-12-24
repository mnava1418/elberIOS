//
//  ViewUtils.swift
//  Elber
//
//  Created by Martin Nava Pe&a on 24/12/20.
//

import Foundation
import UIKit

struct ViewUtils {
    public static func getAnimation() -> CAAnimationGroup{
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse]
        
        return animationGroup
    }
}
