//
//  ViewController.swift
//  SwipeCards
//
//  Created by Andrei Baches on 03/02/2021.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var tipCardsContainerView: SwipeableCardViewContainer!
    
    
    //MARK: Variables
    var dataSource: [Int] = Array(0...4)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tipCardsContainerView.dataSource = self
        self.tipCardsContainerView.delegate = self

        self.tipCardsContainerView.reloadData()
    }


}

//MARK: - SwipeableCardViewDataSource
extension ViewController: SwipeableCardViewDataSource {
    func numberOfCards() -> Int {
        return dataSource.count
    }
    
    func card(forItemAtIndex index: Int) -> SwipeableCardView {
        let card: TipCardView = .fromNib()
        card.setupCard(dataSource: self.dataSource[index])
        
        return card
    }
    
    func viewForEmptyCards() -> UIView? {
        nil
    }
}

//MARK: - SISwipeableViewContainerDelegate
extension ViewController: SwipeableViewContainerDelegate {

    func didTapTipCard() {
        //tapped card
    }
    
    func didSelectTip() {
        //swipe down
    }
    
    func didRemoveTip() {
        //swipe up
    }
    
    func didEmptyTips(isEmpty: Bool) {
        
    }
    
}
