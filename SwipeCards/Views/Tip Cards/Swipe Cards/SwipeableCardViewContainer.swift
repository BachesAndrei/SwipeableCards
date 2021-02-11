//
//  SwipeableCardViewContainer.swift
//  SwipeCards
//
//  Created by Andrei Baches on 03/02/2021.
//

import UIKit

protocol SwipeableViewDelegate: class {
    func didTap(view: SwipeableCardView)
    func didBeginSwipe(onView view: SwipeableCardView)
    func didEndSwipe(onView view: SwipeableCardView, direction: UISwipeGestureRecognizer.Direction )
}

protocol SwipeableViewContainerDelegate {
    func didTapTipCard()
    func didSwipeUp()
    func didSwipeDown()
    func didEmptyTips(isEmpty: Bool)
}


/// A DataSource for providing all of the information required
/// for SwipeableCardViewContainer to layout a series of cards.
protocol SwipeableCardViewDataSource: class {
    
    /// Determines the number of cards to be added into the
    /// SwipeableCardViewContainer. Not all cards will initially
    /// be visible, but as cards are swiped away new cards will
    /// appear until this number of cards is reached.
    ///
    /// - Returns: total number of cards to be shown
    func numberOfCards() -> Int
    
    /// Provides the Card View to be displayed within the
    /// SwipeableCardViewContainer. This view's frame will
    /// be updated depending on its current index within the stack.
    ///
    /// - Parameter index: index of the card to be displayed
    /// - Returns: card view to display
    func card(forItemAtIndex index: Int) -> SwipeableCardView
    
    /// Provides a View to be displayed underneath all of the
    /// cards when all cards have been swiped away.
    ///
    /// - Returns: view to be displayed underneath all cards
    func viewForEmptyCards() -> UIView?
    
}

class SwipeableCardViewContainer: UIView, SwipeableViewDelegate {

    //MARK: - Configuration
    
    ///Inset difference between two cards stacked one on top of each other
    static let horizontalInset: CGFloat = 30.0
    
    ///Scale difference between two cards stacked on top of each other
    static let scaleFactor: CGFloat = 0.13
    
    ///Maximum number of cards that are visible in the stack
    static let numberOfVisibleCards: Int = 3
    

    //MARK: - Variables
    
    ///All cards that will be displayed inside the container
    private var cardViews: [SwipeableCardView] = []
    
    ///The currently displayed cards inside the container
    private var visibleCardViews: [SwipeableCardView] {
        return subviews as? [SwipeableCardView] ?? []
    }
    
    ///The number of cards that remain to be displayed inside the container after the user swipes the visible ones
    private var remainingCards: Int = 0
    
    
    ///The card on top of the stack displayed inside the container
    private var topCard: SwipeableCardView? {
        get {
            return visibleCardViews.last
        }
    }
    
    var dataSource: SwipeableCardViewDataSource?
    
    var delegate: SwipeableViewContainerDelegate?
    
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.topCard?.setupGestureRecognizers()
        
        self.delegate?.didEmptyTips(isEmpty: (visibleCardViews.count == 0))
    }

    //MARK: - Setup
    
    /// Reloads the data used to layout card views in the
    /// card stack. Removes all existing card views and
    /// calls the dataSource to layout new card views.
    func reloadData() {
        removeAllCardViews()
        
        guard let dataSource = dataSource else {
            return
        }
        
        let numberOfCards = dataSource.numberOfCards()
        remainingCards = numberOfCards
        
        for index in 0..<min(numberOfCards, SwipeableCardViewContainer.numberOfVisibleCards) {
            addCardView(cardView: dataSource.card(forItemAtIndex: index), atIndex: index)
        }
        
        setNeedsLayout()
    }
    
    
    ///Sets the frame of the card and inserts it in the stack of cards that are displayed.
    ///
    /// - Parameters:
    ///   - cardView: card view to be added inside the stack
    ///   - index: the new index of the card, used to apply horizontal and vertical insets
    private func addCardView(cardView: SwipeableCardView, atIndex index: Int) {
        cardView.containerDelegate = self
        
        setFrame(forCardView: cardView, atIndex: index)
        cardViews.append(cardView)
        insertSubview(cardView, at: 0)
        remainingCards -= 1
    }
    
    
    ///Removes all visible cards from the stack and clears the cached cards data
    private func removeAllCardViews() {
        for cardView in visibleCardViews {
            cardView.removeFromSuperview()
        }
        cardViews = []
    }
    
    /// Sets the frame of a card view provided for a given index. Applies a specific
    /// horizontal and vertical offset relative to the index in order to create an
    /// overlay stack effect on a series of cards.
    ///
    /// - Parameters:
    ///   - cardView: card view to update frame on
    ///   - index: index used to apply horizontal and vertical insets
    private func setFrame(forCardView cardView: SwipeableCardView, atIndex index: Int) {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalTo: self.heightAnchor),
            cardView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.95)
        ])
        
        
        var cardViewFrame =  CGRect(x: 0, y: 0, width: cardView.frame.width, height: cardView.frame.height)
        
        let horizontalInset = CGFloat(index) * SwipeableCardViewContainer.horizontalInset
        let scale = 1.0 - CGFloat(index) * SwipeableCardViewContainer.scaleFactor
        let customTransform  = CGAffineTransform.identity
            .translatedBy(x: horizontalInset, y: 0)
            .scaledBy(x: scale, y: scale)
        
        cardView.layer.transform = CATransform3DMakeAffineTransform(customTransform)
        
        
        cardViewFrame.origin.x += horizontalInset
        cardView.frame = cardViewFrame
    }
    
    /// Sets the new position of a card view provided for a given index.
    ///
    /// - Parameters:
    ///   - cardView: card view to update position on
    ///   - index: the new index of the card, used to apply horizontal and vertical insets
    func bringForward(_ cardView: SwipeableCardView, atIndex index: Int) {
        let horizontalInset = CGFloat(index) * SwipeableCardViewContainer.horizontalInset
        let scale = 1.0 - CGFloat(index) * SwipeableCardViewContainer.scaleFactor
        let customTransform  = CGAffineTransform.identity
            .translatedBy(x: horizontalInset, y: 0)
            .scaledBy(x: scale, y: scale)
        
        cardView.layer.transform = CATransform3DMakeAffineTransform(customTransform)
    }
    
}

// MARK: - SwipeableViewDelegate

extension SwipeableCardViewContainer {
    
    func didTap(view: SwipeableCardView) {
        delegate?.didTapTipCard()
    }
    
    func didBeginSwipe(onView view: SwipeableCardView) {
        // React to Swipe Began?
    }
    
    func didEndSwipe(onView view: SwipeableCardView, direction: UISwipeGestureRecognizer.Direction) {
        guard let dataSource = dataSource else {
            return
        }
        
        if direction == .down {
            delegate?.didSwipeUp()
        }else {
            delegate?.didSwipeDown()
        }
        
        // Remove swiped card
        view.removeFromSuperview()
        
        // Update all existing card's frames based on new indexes, animate frame change
        // to reveal new card from underneath the stack of existing cards.
        for (cardIndex, cardView) in visibleCardViews.reversed().enumerated() {
            UIView.animate(withDuration: 0.2, animations: {
                self.bringForward(cardView, atIndex: cardIndex)
                self.layoutIfNeeded()
            })
        }
        
        
        // Only add a new card if there are cards remaining
        if remainingCards > 0 {
            
            // Calculate new card's index
            let newIndex = dataSource.numberOfCards() - remainingCards
            
            // Add new card as Subview
            addCardView(cardView: dataSource.card(forItemAtIndex: newIndex), atIndex: self.visibleCardViews.count)
        }
        
    }
    
}

