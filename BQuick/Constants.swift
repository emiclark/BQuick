//
//  Constants.swift
//  BQuick
//
//  Created by Emiko Clark on 8/16/17.
//  Copyright © 2017 Emiko Clark. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    
    struct Values {
        // set misc variables
        static let gameTime = 45
        static let myBlueColor = UIColor(red: 10/255, green: 100/255, blue: 150/255, alpha: 1)
    }
    
    struct Strings {
        // set header/footer text
        static let gameOverHeader = "Game Over\n"
        static let finalScore1 = "Word Guessed Correctly out of"
        static let finalScore2 = "Words Correct Out Of"
        static let missedWordHeader = "Missed Words\n"
        static let correctWordHeader = "Correctly Guessed Words\n"
        static let footerString = "Note: If both the correct and the misspelled word appears during the game, the correct word and it's definition will appear once based on your first guess.\n"
    }
    
    struct AttributeDefinition {
        // define styles, create headers, missed words and guessed correctly lists to display when game is over set attributes for headers and Notes
        
        private static var paraCenter: NSMutableParagraphStyle  {
            let paraC = NSMutableParagraphStyle()
            paraC.alignment = .center
            paraC.paragraphSpacing = 10
            paraC.paragraphSpacingBefore = 20
            paraC.lineSpacing = 1
            return paraC
        }

        static var paraLeft1: NSMutableParagraphStyle  {
            let paraL1 = NSMutableParagraphStyle()
            paraL1.alignment = .left
            paraL1.paragraphSpacing = 5
            paraL1.lineSpacing = 0.5
            return paraL1
        }

        static var paraLeft2: NSMutableParagraphStyle  {
            let paraL2 = NSMutableParagraphStyle()
            paraL2.alignment = .left
            paraL2.paragraphSpacing = 10
            paraL2.lineSpacing = 1
            return paraL2
        }
        
        private static var paraJust: NSMutableParagraphStyle  {
            let paraJ = NSMutableParagraphStyle()
            paraJ.alignment = .justified
            paraJ.paragraphSpacing = 10
            paraJ.paragraphSpacingBefore = 10
            paraJ.lineSpacing = 1
            return paraJ
        }

        public static let header22BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 22) ?? UIFont.boldSystemFont(ofSize: 22),
            NSForegroundColorAttributeName: Constants.Values.myBlueColor,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        public static let header20BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 20) ?? UIFont.boldSystemFont(ofSize: 20),
            NSForegroundColorAttributeName: Constants.Values.myBlueColor,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        public static let header17BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 17) ?? UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName: Constants.Values.myBlueColor,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        public static let header17BoldBR: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 17) ?? UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName: UIColor.brown,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        public static let missedWord16BoldBR: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.brown,
            NSParagraphStyleAttributeName: paraLeft1
        ]
        
        public static let correctWord16BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: Constants.Values.myBlueColor,
            NSParagraphStyleAttributeName: paraLeft1
        ]
        
        public static let definition14GR: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 14) ?? UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.darkGray,
            NSParagraphStyleAttributeName: paraLeft1
        ]
        
        public static let footer12GR: [String: Any] = [
            NSFontAttributeName : UIFont(name: "Chalkboard SE", size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSForegroundColorAttributeName : UIColor.darkGray,
            NSParagraphStyleAttributeName: paraJust
            ] as [String : Any]
    }
    
    
}
