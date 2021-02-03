//
//  UIView.swift
//  SwipeCards
//
//  Created by Andrei Baches on 03/02/2021.
//

import UIKit


//MARK: Load nib file
extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    class func fromNib<T: UIView>(with name: String) -> T{
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)![0] as! T
    }
    
}
