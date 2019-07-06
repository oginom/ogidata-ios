//
//  MenuViewBase.swift
//  OgiData3
//
//  Created by ma on 2018/05/08.
//  Copyright © 2018年 Masahiro Ogino. All rights reserved.
//

import UIKit
import Cartography

class MenuViewBase : UIView {
    
    private var didSetupConstraints : Bool = false
    
    private let screenView = UIButton()
    
    public let menuButton = UIButton()
    
    public var buttons : [UIButton] = []
    
    private let buttonsConstraint = ConstraintGroup()
    
    public var isButtonsOpen = false
    
    private var isButtonsAnimating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder? = nil) {
        if let coder = coder {
            super.init(coder: coder)
        } else {
            super.init(frame: CGRect.zero)
        }
        setup()
    }
    
    func setup() {
        
        screenView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        screenView.addTarget(self, action: #selector(DataViewMenuView.tapScreenView), for: .touchUpInside)
        screenView.isHidden = true
        self.addSubview(screenView)
        
        setupButtons()
        
        menuButton.setTitle("MENU", for: .normal)
        menuButton.backgroundColor = .black
        menuButton.layer.cornerRadius = 40
        menuButton.addTarget(self, action: #selector(DataViewMenuView.tapMenuButton), for: .touchUpInside)
        self.addSubview(menuButton)
        
    }
    
    func setupButtons() {
        _ = addMenuButton(name:"a", color:UIColor.white)
    }
    
    func addMenuButton(name:String, color:UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(name, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6
        button.backgroundColor = color
        button.layer.cornerRadius = 40
        button.isHidden = true
        self.addSubview(button)
        buttons.append(button)
        return button
    }
    
    func setupConstraints() {
        constrain(screenView) {
            screenView in
            screenView.edges == screenView.superview!.edges
        }
        constrain(menuButton) {
            menuButton in
            menuButton.width == 80
            menuButton.height == 80
            menuButton.right == menuButton.superview!.right - 20
            menuButton.bottom == menuButton.superview!.bottom - 20
        }
        constrain(buttons) {
            buttons in
            for button in buttons {
                button.width == 80
                button.height == 80
                button.right == button.superview!.right - 20
            }
        }
        closedConstrain()
        
        updateConstraints()
    }
    func openedConstrain() {
        constrain(buttons, replace: buttonsConstraint) {
            buttons in
            distribute(by: 20.0, vertically: buttons)
            buttons[buttons.count - 1].bottom == buttons[buttons.count - 1].superview!.bottom - 120.0
        }
    }
    func closedConstrain() {
        constrain(buttons, replace: buttonsConstraint) {
            buttons in
            for button in buttons {
                button.bottom == button.superview!.bottom - 20
            }
        }
    }
    
    override func layoutSubviews() {
        if !didSetupConstraints {
            self.setupConstraints()
            didSetupConstraints = true
        }
    }
    
    func tapScreenView(_ sender: UIButton) {
        print(sender.title(for: .normal) ?? "NO_TITLE")
        if (isButtonsOpen) {
            closeButtons()
        }
    }
    
    func tapMenuButton(_ sender: UIButton) {
        print(sender.title(for: .normal) ?? "NO_TITLE")
        if (isButtonsOpen) {
            closeButtons()
        } else {
            openButtons()
        }
    }
    
    func openButtons() {
        if (isButtonsAnimating) {
            return
        }
        isButtonsAnimating = true
        screenView.isHidden = false
        for button in buttons {
            button.isHidden = false
        }
        openedConstrain()
        UIView.animate(withDuration: 0.25, animations: self.layoutIfNeeded, completion: {
            (finished: Bool) in
            self.isButtonsAnimating = false
            self.isButtonsOpen = true
        })
    }
    
    func closeButtons() {
        if (isButtonsAnimating) {
            return
        }
        isButtonsAnimating = true
        screenView.isHidden = true
        closedConstrain()
        UIView.animate(withDuration: 0.25, animations: self.layoutIfNeeded, completion: {
            (finished: Bool) in
            for button in self.buttons {
                button.isHidden = true
            }
            self.isButtonsAnimating = false
            self.isButtonsOpen = false
        })
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for ch in self.subviews {
            if !ch.isHidden && ch.frame.contains(point) {
                return true
            }
        }
        return false
    }
}
