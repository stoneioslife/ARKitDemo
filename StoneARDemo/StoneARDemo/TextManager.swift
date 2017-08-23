//
//  TextManager.swift
//  StoneARDemo
//
//  Created by stone on 2017/8/23.
//  Copyright © 2017年 NgariHealth. All rights reserved.
//

import UIKit

enum MessageType {
    case trackingStateEscalation
    case planeEstimation
    case contentPlacement
    case focusSquare
}

class TextManager {
    
    private var viewController: ViewController!
    
    private var messageHideTimer: Timer?
    private var debugMessageHideTimer: Timer?
    
    private var focusSquareMessageTimer: Timer?
    private var planeEstimationMessageTimer: Timer?
    private var contentPlacementMessageTimer: Timer?
    
    private var trackingStateFeedbackEsacalationTimer: Timer?
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    func showMessage(_ text: String, autoHide: Bool = true) {
        messageHideTimer?.invalidate();
        
        
    }
}
