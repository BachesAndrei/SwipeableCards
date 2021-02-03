//
//  TipCard.swift
//  SwipeCards
//
//  Created by Andrei Baches on 03/02/2021.
//

import UIKit

class TipCardView: SwipeableCardView {
    //MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Setup
    func setupCard(dataSource: Int) {
        self.titleLabel.text = "Card #\(dataSource)"
    }
}
