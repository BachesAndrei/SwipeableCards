//
//  SISwipeableCardView.swift
//  SwipeCards
//
//  Created by Andrei Baches on 03/02/2021.
//

import UIKit

class SwipeableCardView: UIView {
    
    // MARK: Configuration
    
    ///Maximum rotation angle to be applied to a card when the user swipes it, where 0 = no rotation and 1 = full rotation
    static var maximumRotation: CGFloat = 0.6

    ///Animation time when resetting the card to the default position, after the user action stops
    static var cardViewResetAnimationDuration: TimeInterval = 0.2
    
    
    // MARK: Outlet - from SITipCardView
    @IBOutlet weak var mainCard: UIView!
    @IBOutlet weak var bottomCard: UIView!
    
    // MARK: Variables
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    var containerDelegate: SwipeableViewDelegate?
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        //TODO: - Remove when implementing custom design
        self.mainCard.layer.borderColor = UIColor.yellow.cgColor
        self.mainCard.layer.borderWidth = 1.0
        
        self.bottomCard.layer.borderColor = UIColor.yellow.cgColor
        self.bottomCard.layer.borderWidth = 1.0
    }
    
    deinit {
        if let panGestureRecognizer = panGestureRecognizer {
            removeGestureRecognizer(panGestureRecognizer)
        }
        
        if let tapGestureRecognizer = tapGestureRecognizer {
            removeGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func setupGestureRecognizers() {
        // Pan Gesture Recognizer
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SwipeableCardView.tapRecognized(_:)))
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeableCardView.panGestureRecognized(_:)))
        
        addGestureRecognizer(tapGestureRecognizer!)
        addGestureRecognizer(panGestureRecognizer!)
    }
    
    func programmaticallySwipeDownCard() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.animateSwipeDown(panGestureTranslation: CGPoint(x: 0, y: self.frame.height / 2))
        }, completion: { (finished: Bool) in
            self.endedPanAnimation(panGestureTranslation: CGPoint(x: 0, y: self.frame.height / 2))
        })
    }
    
    // MARK: - Tap Gesture Recognizer
    
    @objc private func tapRecognized(_ recognizer: UITapGestureRecognizer) {
        self.containerDelegate?.didTap(view: self)
    }
    
    // MARK: - Pan Gesture Recognizer
    
    @objc private func panGestureRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        let panGestureTranslation = gestureRecognizer.translation(in: self)
        
        //y positive -> should move just the bottom card
        
        switch gestureRecognizer.state {
            case .began:
                setCardNewAnchorPoint(gestureRecognizer)
            //            delegate?.didBeginSwipe(onView: self)
            case .changed:
                if panGestureTranslation.y > 0 {
                    //swipe down
                    self.animateSwipeDown(panGestureTranslation: panGestureTranslation)
                } else {
                    //swipe up
                    self.animateSwipeUp(panGestureTranslation: panGestureTranslation)
                }
            case .ended:
                endedPanAnimation(panGestureTranslation: panGestureTranslation)
                layer.shouldRasterize = false
            default:
                resetCardViewPosition()
                layer.shouldRasterize = false
        }
    }
    
    
    private func setCardNewAnchorPoint(_ gestureRecognizer: UIPanGestureRecognizer) {
        let initialTouchPoint = gestureRecognizer.location(in: self)
        let newAnchorPoint = CGPoint(x: initialTouchPoint.x / bounds.width, y: initialTouchPoint.y / bounds.height)
        let oldPosition = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
        let newPosition = CGPoint(x: bounds.size.width * newAnchorPoint.x, y: bounds.size.height * newAnchorPoint.y)
        layer.anchorPoint = newAnchorPoint
        layer.position = CGPoint(x: layer.position.x - oldPosition.x + newPosition.x, y: layer.position.y - oldPosition.y + newPosition.y)
        
        removeAnimations()
        layer.rasterizationScale = UIScreen.main.scale
        layer.shouldRasterize = true
    }
    
    
    //MARK: - Animations
    
    ///Animates the card when the user swipes up.
    ///All animations are determined based on the default card position (before swipe) and the distance the user swiped up
    private func animateSwipeUp(panGestureTranslation: CGPoint) {
        resetBottomCardViewPosition()
        resetMainCardViewPosition()
        
        let rotationStrenght = -min(panGestureTranslation.y / 360, SwipeableCardView.maximumRotation)
        let rotationAngle = rotationStrenght * SwipeableCardView.maximumRotation
        
        let xTranslation = max(panGestureTranslation.y / 4, -panGestureTranslation.y / 4)
        let yTranslation = panGestureTranslation.y * 1.5
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
        transform = CATransform3DTranslate(transform, xTranslation, yTranslation, 0)
        
        layer.transform = transform
    }
    
    ///Animates the card when the user swipes down.
    ///All animations are determined based on the default card position (before swipe) and the distance the user swiped down.
    ///For a swipe down animation, the top and bottom cards will have different animations
    private func animateSwipeDown(panGestureTranslation: CGPoint) {
        resetCardViewPosition()
        
        animateBottomCard(panGestureTranslation: panGestureTranslation)
        animateMainCard(panGestureTranslation: panGestureTranslation)
    }
    
    private func animateBottomCard(panGestureTranslation: CGPoint) {
        let rotationStrenght = -min(panGestureTranslation.y / 360, SwipeableCardView.maximumRotation)
        let rotationAngle = rotationStrenght * SwipeableCardView.maximumRotation
        
        let yTranslation = panGestureTranslation.y
        
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, yTranslation, 0)
        transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
        
        bottomCard.layer.transform = transform
    }
    
    private func animateMainCard(panGestureTranslation: CGPoint) {
        let rotationStrenght = -panGestureTranslation.y / 180
        let rotationAngle = rotationStrenght * SwipeableCardView.maximumRotation
        
        let xTranslation = -max(panGestureTranslation.y, -panGestureTranslation.y) * 1.5
        let yTranslation = -panGestureTranslation.y
        
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, xTranslation, yTranslation, 0)
        transform = CATransform3DRotate(transform, rotationAngle, 0, 0, 1)
        
        mainCard.layer.transform = transform
    }
    
    private func endedPanAnimation(panGestureTranslation: CGPoint) {
        //if the swipe distance is longer than third of the card height, the swipe will be considered a complete action
        if abs(panGestureTranslation.y) > self.frame.height * 0.3 {
            UIView.animate(withDuration: 0.15, animations: {
                self.alpha = 0.4
            }) { finished in
                self.containerDelegate?.didEndSwipe(onView: self, direction: panGestureTranslation.y > 0 ? .down : .up)
            }
            
            return
        }
        
        //The swipe action is not complete and the card will revert to the default position
        resetCardViewPosition()
        resetBottomCardViewPosition()
        resetMainCardViewPosition()
    }
    
    private func resetBottomCardViewPosition() {
        UIView.animateKeyframes(withDuration: SwipeableCardView.cardViewResetAnimationDuration, delay: 0.0, options: .allowUserInteraction, animations: {
            self.bottomCard.layer.transform = CATransform3DIdentity
            self.mainCard.alpha = 1.0
        }, completion: { _ in
            self.bottomCard.layer.transform = CATransform3DIdentity
            self.mainCard.alpha = 1.0
        })
    }
    
    private func resetMainCardViewPosition() {
        UIView.animateKeyframes(withDuration: SwipeableCardView.cardViewResetAnimationDuration, delay: 0.0, options: .allowUserInteraction, animations: {
            self.mainCard.layer.transform = CATransform3DIdentity
        }, completion: { _ in
            self.mainCard.layer.transform = CATransform3DIdentity
        })
    }
    
    private func resetCardViewPosition() {
        //        self.alpha = 1.0
        UIView.animateKeyframes(withDuration: SwipeableCardView.cardViewResetAnimationDuration, delay: 0.0, options: .allowUserInteraction, animations: {
            self.layer.transform = CATransform3DIdentity
        }, completion: { _ in
            self.layer.transform = CATransform3DIdentity
        })
    }
    
    private func removeAnimations() {
        self.layer.removeAllAnimations()
    }
    
}
