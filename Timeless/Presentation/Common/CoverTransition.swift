//
//  CoverTransition.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit

enum CoverTransitionStyle {
    case light
    case dark
}

enum CoverTransitionOffset {
    case base
    case inverted
}

class CoverTransition: NSObject, UIViewControllerTransitioningDelegate {
    
    let offsetTop: CGFloat
    let headerColor: UIColor?
    let style: CoverTransitionStyle
    let animator = CoverTransitionAnimator()
    var presentationController: CoverPresentationController!
    
    init(withStyle style: CoverTransitionStyle = .light, offset: CoverTransitionOffset = .base, headerColor: UIColor? = nil) {
        self.style = style
        self.headerColor = headerColor
        self.offsetTop = 20.0 * (offset == .inverted ? -1 : 1)
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presentationController = CoverPresentationController(presentedViewController: presented, presenting: presenting, style: style, headerColor: headerColor)
        presentationController.offsetTop = offsetTop
        
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presentAnimation = true
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presentAnimation = false
        
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentationController.interaction
    }
    
}

class CoverTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presentAnimation = false
    
    private var snapshot: UIView?
    private let animationDuration: TimeInterval = 0.4
    private let dismissedScaleOffset: CGFloat = 8.0
    private let cornerRadius: CGFloat = 4.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated ?? false ? animationDuration : 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) ?? fromViewController.view,
            let toView = transitionContext.view(forKey: .to) ?? toViewController.view
            else { return assert(false, "Invalid transitionContext for CoverTransitionAnimator") }
        
        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        let toFinalFrame = transitionContext.finalFrame(for: toViewController)
        let toFinalTransform = CGAffineTransform.identity
        let dismissedScale = (toFinalFrame.width - 2 * dismissedScaleOffset) / toFinalFrame.width
        let backViewTranslationY = UIApplication.shared.statusBarFrame.height - containerView.bounds.height * (1.0 - dismissedScale) / 2.0
        let backViewTransform = CGAffineTransform(translationX: 0.0, y: backViewTranslationY).scaledBy(x: dismissedScale, y: dismissedScale)
        
        if presentAnimation {
            guard let snapshot = fromView.snapshotView(afterScreenUpdates: false) else { return assert(false, "Failed to create snapshot") }
            
            snapshot.layer.cornerRadius = cornerRadius
            snapshot.layer.masksToBounds = true
            toView.transform = toFinalTransform.translatedBy(x: 0.0, y: toFinalFrame.height)
            containerView.addSubview(snapshot)
            containerView.addSubview(toView)
            fromView.isHidden = true
            
            self.snapshot = snapshot
            
            UIApplication.shared.keyWindow?.backgroundColor = .lightGray
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
                toView.transform = toFinalTransform
                snapshot.transform = backViewTransform
                snapshot.alpha = 0.5
            }, completion: { finished in
                let wasCancelled = transitionContext.transitionWasCancelled
                
                if wasCancelled {
                    snapshot.removeFromSuperview()
                    toView.removeFromSuperview()
                    self.snapshot = nil
                }
                
                transitionContext.completeTransition(!wasCancelled)
            })
        } else {
            guard let snapshot = snapshot else { return assert(false, "Cannot transition if snapshot is nil") }
            
            let fromFinalTransform = toFinalTransform.translatedBy(x: 0.0, y: toFinalFrame.height)
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: {
                fromView.transform = fromFinalTransform
                snapshot.transform = toFinalTransform
                snapshot.alpha = 1.0
            }, completion: { finished in
                let wasCancelled = transitionContext.transitionWasCancelled
                
                if !wasCancelled {
                    snapshot.removeFromSuperview()
                    toView.isHidden = false
                    self.snapshot = nil
                }
                
                transitionContext.completeTransition(!wasCancelled)
            })
        }
    }
    
}

class CoverPresentationController: UIPresentationController {
    
    var offsetTop: CGFloat = 20.0
    var interaction: UIPercentDrivenInteractiveTransition?
    
    private let headerHeight: CGFloat = 44.0
    private let cornerRadius: CGFloat = 4.0
    
    private let wrapperView: UIView
    private let headerView: UIView
    private let gradientLayer: CAGradientLayer?
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(recognizer:)))
    private lazy var panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
    private lazy var swipeRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(recognizer:)))
        recognizer.direction = .down
        return recognizer
    }()
    
    override var shouldPresentInFullscreen: Bool { return false }
    
    override var presentedView: UIView? { return wrapperView }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let insets = UIEdgeInsets(top: offsetTop + UIApplication.shared.statusBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0)
        
        return containerView.bounds.inset(by: insets)
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, style: CoverTransitionStyle, headerColor: UIColor?) {
        let wrapperView = UIView(frame: .zero)
        wrapperView.layer.cornerRadius = cornerRadius
        wrapperView.layer.masksToBounds = true
        wrapperView.backgroundColor = .white
        let headerView = UIView(frame: .zero)
        headerView.backgroundColor = .clear
        
        if let headerColor =  headerColor {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [headerColor.cgColor, UIColor(white: 1.0, alpha: 0.0).cgColor]
            gradientLayer.locations = [NSNumber(value: 0.8), NSNumber(value: 1.0)]
            headerView.layer.addSublayer(gradientLayer)
            self.gradientLayer = gradientLayer
        } else {
            self.gradientLayer = nil
        }
        
        let imageView = UIImageView(frame: headerView.frame)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .center
        imageView.image = UIImage(named: style == .light ? "down_gray_icon" : "down_light_icon")
        headerView.addSubview(imageView)
        
        self.wrapperView = wrapperView
        self.headerView = headerView
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = super.presentedView else { return assert(false, "presentedView should not be nil") }
        
        let presentedFrame = frameOfPresentedViewInContainerView
        
        presentedView.frame = CGRect(origin: .zero, size: presentedFrame.size)
        presentedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedView.addGestureRecognizer(swipeRecognizer)
        wrapperView.frame = presentedFrame.inset(by: UIEdgeInsets(top: 0.0, left: 0.0, bottom: -cornerRadius, right: 0.0))
        wrapperView.addSubview(presentedView)
        
        headerView.frame = CGRect(origin: .zero, size: CGSize(width: presentedFrame.width, height: headerHeight))
        headerView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        tapRecognizer.require(toFail: panRecognizer)
        headerView.addGestureRecognizer(panRecognizer)
        headerView.addGestureRecognizer(tapRecognizer)
        gradientLayer?.frame = headerView.bounds
        wrapperView.addSubview(headerView)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            tapRecognizer.removeTarget(nil, action: nil)
            panRecognizer.removeTarget(nil, action: nil)
            swipeRecognizer.removeTarget(nil, action: nil)
            wrapperView.removeFromSuperview()
            headerView.removeFromSuperview()
        }
    }
    
    @objc private func dismiss(recognizer: UISwipeGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc private func panAction(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            interaction = UIPercentDrivenInteractiveTransition()
            presentedViewController.dismiss(animated: true, completion: nil)
        case .changed:
            interaction?.update(percent(for: recognizer))
        case .ended, .cancelled, .failed:
            if percent(for: recognizer) > 0.3 {
                interaction?.finish()
            } else {
                interaction?.cancel()
            }
            
            interaction = nil
        default: break
        }
    }
    
    @objc private func tapAction(recognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    private func percent(for recognizer: UIPanGestureRecognizer) -> CGFloat {
        guard let containerView = containerView else { return 0.0 }
        
        let translation = recognizer.translation(in: containerView)
        
        return translation.y / containerView.bounds.height
    }
    
}
