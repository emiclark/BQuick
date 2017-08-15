//
//  DAO.swift
//  BQuick
//
//  Created by Emiko Clark on 5/23/17.
//  Copyright © 2017 Emiko Clark. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class DAO: NSObject {
    
    //MARK: Shared Instance
    
    static let sharedInstance = DAO()
    
    //MARK: Local Variable
    var soundON: Bool = true
    var backgroundMusic = AVAudioPlayer()

    var nextWord: Word?
    var wordDisplayed: String = ""
    var wordsDisplayedDict = [String : Bool]()
    var guessedRightDict = [String: String]()
    var guessedWrongDict = [String: String]()
    
    var mainWordsArray = [Word]()
    
    var wordAlreadyDisplayed = false
    var guessedCorrect: Bool = false
    var didSwipeRight = false //
    var didSwipeLeft = false
    var scored = 0
    var totalNumWordsDisplayed = 0
    var totalWords = 0   // total words available to play
    var playGame = false
    
    let instructionsTextViewString = NSMutableAttributedString()
    var missedWordsAttributedTextString = NSMutableAttributedString()
    var correctWordsAttributedTextString = NSMutableAttributedString()
    var finalOutput = NSMutableAttributedString()
    
    
    private override init() {
        super.init()
        
        // init audioPlayer
        let musicFileString = Bundle.main.path(forResource: "flight_of_the_bumblebee", ofType: "mp3")!
        let musicFileURL = URL(string: musicFileString)
        self.backgroundMusic = try! AVAudioPlayer.init(contentsOf: musicFileURL!)
        self.backgroundMusic.numberOfLoops = -1
        self.backgroundMusic.play()
        
        makeWordsArrayFromJSON()
    }
    
    private func makeWordsArrayFromJSON(){
        // parses json file and populates wordListArray
        do {

            let file = Bundle.main.path(forResource: "words-master", ofType: "json")
            let data = try? Data(contentsOf: URL(fileURLWithPath: file!))
        
            // convert and parse json
            let json = JSON(data: data!)
            let wordsArrayJson = json["WordsArray"].arrayValue

            for subJsonArray in wordsArrayJson {
                let wordArray = subJsonArray["word"].arrayValue
                let definition = subJsonArray["definition"].stringValue
                
                var finalWordArray = [String]()
                
                for eachWord in wordArray  {
                    finalWordArray.append(eachWord.stringValue.lowercased())
                    totalWords += 1
                }
                
                let newWord = Word(wordsArray: finalWordArray, definition: definition)
                self.mainWordsArray.append(newWord)
                print("newWord: ", newWord.wordsArray, newWord.definition)
            }
        }
        print("totalWords: ", totalWords)
    }
    
    // MARK: - reset game

    func resetGameOverWordsList(){
        
        // reset properties for a new game
        missedWordsAttributedTextString = NSMutableAttributedString(string: "")
        correctWordsAttributedTextString = NSMutableAttributedString(string: "")
        finalOutput = NSMutableAttributedString(string: "")
        
        scored = 0
        totalNumWordsDisplayed = 0
        guessedCorrect = false
        wordsDisplayedDict.removeAll()
        guessedRightDict.removeAll()
        guessedWrongDict.removeAll()
    }
    
    
    // MARK: - attributed Text Methods
    
    func createScoreOutput() {
        // define styles, create headers, missed words and guessed correctly lists to display when game is over
        // set attributes for headers and Notes
        let paraCenter = NSMutableParagraphStyle()
        paraCenter.alignment = .center
        paraCenter.paragraphSpacing = 10
        paraCenter.paragraphSpacingBefore = 20
        paraCenter.lineSpacing = 1
        
        let paraLeft = NSMutableParagraphStyle()
        paraLeft.alignment = .left
        paraLeft.lineSpacing = 0.5
        paraLeft.paragraphSpacing = 5
        
        let paraLeft2 = NSMutableParagraphStyle()
        paraLeft2.alignment = .left
        paraLeft2.lineSpacing = 1
        paraLeft2.paragraphSpacing = 10
        
        let paraJust = NSMutableParagraphStyle()
        paraJust.alignment = .justified
        paraJust.lineSpacing = 1
        paraJust.paragraphSpacing = 10
        paraJust.paragraphSpacingBefore = 10


        let missedWord16BoldBR: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.brown,
            NSParagraphStyleAttributeName: paraLeft
        ]
        
        let correctWord16BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: myBlueColor,
            NSParagraphStyleAttributeName: paraLeft
        ]
        
        let definition14GR: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 14) ?? UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.darkGray,
            NSParagraphStyleAttributeName: paraLeft
        ]
        
        // set attributes
        let header22BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 22) ?? UIFont.boldSystemFont(ofSize: 22),
            NSForegroundColorAttributeName: myBlueColor,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        let header20BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 20) ?? UIFont.boldSystemFont(ofSize: 20),
            NSForegroundColorAttributeName: myBlueColor,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        let header17BoldBL: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 17) ?? UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName: myBlueColor,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        let header17BoldBR: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 17) ?? UIFont.boldSystemFont(ofSize: 17),
            NSForegroundColorAttributeName: UIColor.brown,
            NSParagraphStyleAttributeName: paraCenter
        ]
        
        let footer12GR: [String: Any] = [
            NSFontAttributeName : UIFont(name: "Chalkboard SE", size: 12) ?? UIFont.systemFont(ofSize: 12),
            NSForegroundColorAttributeName : UIColor.darkGray,
            NSParagraphStyleAttributeName: paraJust
            ] as [String : Any]
        
        
        // set header/footer text
        let gameOverHeaderString = "Game Over\n"
        let finalScoreString1 = "\(scored) Word Guessed Correctly out of \(totalNumWordsDisplayed)\n"
        let finalScoreString2 = "\(scored) Words Correct Out Of \(totalNumWordsDisplayed)\n"
        let missedWordHeaderString = "Missed Words\n"
        let correctWordHeaderString = "Correctly Guessed Words\n"
        let footerString = "Note: If both the correct and the misspelled word appears during the game, the correct word and it's definition will appear once based on your first guess.\n"
        
        let gameOverHeader = NSAttributedString(string: gameOverHeaderString, attributes: header22BoldBL)
        var finalScore = NSAttributedString(string: finalScoreString2, attributes: header20BoldBL)
        
        if scored == 1 {
            finalScore = NSAttributedString(string: finalScoreString1, attributes: header20BoldBL)
        }
        
        let missedWordHeader = NSAttributedString(string: missedWordHeaderString, attributes: header17BoldBR)
        let correctWordHeader = NSAttributedString(string: correctWordHeaderString, attributes: header17BoldBL)
        let footer = NSAttributedString(string: footerString, attributes: footer12GR)
        
        finalOutput.append(gameOverHeader)
        finalOutput.append(finalScore)

        if guessedWrongDict.count > 0 {
            // prepare list for words that were guessed wrong
            finalOutput.append(missedWordHeader)
            
            for (word,def) in guessedWrongDict {
                
                // create and format word+definition string and apply attributes
                let correctWord = NSAttributedString(string: word.initialCaps() + ": ", attributes: missedWord16BoldBR)
                let definition = NSAttributedString(string: def.initialCaps() + "\n" , attributes: definition14GR)
                
                // add lines to missedWordsList - word.wordsArray[0] is the correct word
                missedWordsAttributedTextString.append(correctWord)
                missedWordsAttributedTextString.append(definition)
                
                // apply paragraph styles to paragraph
                missedWordsAttributedTextString.addAttribute(NSParagraphStyleAttributeName, value: paraLeft, range: NSRange(location: 0, length: missedWordsAttributedTextString.length))
            }
            // append guessedWrong words
            finalOutput.append(missedWordsAttributedTextString)
        }

        if guessedRightDict.count > 0 {
            
            // prepare correctly guessed words list
            finalOutput.append(correctWordHeader)
            
            for (word,def) in guessedRightDict {
                
                // create and format word+definition string and apply attributes
                let correctWord = NSAttributedString(string: word.initialCaps() + ": ", attributes: correctWord16BoldBL)
                let definition = NSAttributedString(string: def.initialCaps() + "\n" , attributes: definition14GR)
                
                // add lines to missedWordsList - word.wordsArray[0] is the correct word
                correctWordsAttributedTextString.append(correctWord)
                correctWordsAttributedTextString.append(definition)
                
                // apply paragraph styles to paragraph
                correctWordsAttributedTextString.addAttribute(NSParagraphStyleAttributeName, value: paraLeft, range: NSRange(location: 0, length: correctWordsAttributedTextString.length))
            }
            // append correctlyGuessed words
            finalOutput.append(correctWordsAttributedTextString)
        }
        
        // append footer
        finalOutput.append(footer)
    }

}
