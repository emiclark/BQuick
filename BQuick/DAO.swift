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
    var totalWords = 0
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
            }
        }
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
        
        let finalScoreString1 = "\(scored) \(Constants.Strings.finalScore1) \(totalNumWordsDisplayed)\n"
        let finalScoreString2 = "\(scored) \(Constants.Strings.finalScore2) \(totalNumWordsDisplayed)\n"
        
        let gameOverHeader = NSAttributedString(string: Constants.Strings.gameOverHeader,  attributes: Constants.AttributeDefinition.header22BoldBL)
        
        var finalScore = NSAttributedString(string: finalScoreString2, attributes: Constants.AttributeDefinition.header20BoldBL)
        
        if scored == 1 {
            finalScore = NSAttributedString(string: finalScoreString1, attributes: Constants.AttributeDefinition.header20BoldBL)
        }
        
        finalOutput.append(gameOverHeader)
        finalOutput.append(finalScore)

        let missedWordHeader = NSAttributedString(string: Constants.Strings.missedWordHeader,  attributes: Constants.AttributeDefinition.header17BoldBR)
        let correctWordHeader = NSAttributedString(string: Constants.Strings.correctWordHeader, attributes: Constants.AttributeDefinition.header17BoldBL)
        let footer = NSAttributedString(string: Constants.Strings.footerString , attributes: Constants.AttributeDefinition.footer12GR)

        if guessedWrongDict.count > 0 {
            // prepare list for words that were guessed wrong
            finalOutput.append(missedWordHeader)
            createMissedWordsList()
            
            // append guessedWrong words
            finalOutput.append(missedWordsAttributedTextString)
        }

        if guessedRightDict.count > 0 {
            
            // prepare correctly guessed words list
            finalOutput.append(correctWordHeader)
            createCorrectlyGuessedWordsList()
            
            // append correctlyGuessed words
            finalOutput.append(correctWordsAttributedTextString)
        }
        // append footer text
        finalOutput.append(footer)
    }

    func createMissedWordsList() {
        for (word,def) in guessedWrongDict {
        
        // create and format word+definition string and apply attributes
        let correctWord = NSAttributedString(string: word.initialCaps() + ": ", attributes: Constants.AttributeDefinition.missedWord16BoldBR)
        let definition = NSAttributedString(string: def.initialCaps() + "\n" , attributes: Constants.AttributeDefinition.definition14GR)
        
        // add lines to missedWordsList - word.wordsArray[0] is the correct word
        missedWordsAttributedTextString.append(correctWord)
        missedWordsAttributedTextString.append(definition)
        
        // apply paragraph styles to paragraph
        missedWordsAttributedTextString.addAttribute(NSParagraphStyleAttributeName, value: Constants.AttributeDefinition.paraLeft2, range: NSRange(location: 0, length: missedWordsAttributedTextString.length))
        }
    }
    
    func createCorrectlyGuessedWordsList() {
        
        for (word,def) in guessedRightDict {
            
            // create and format word+definition string and apply attributes
            let correctWord = NSAttributedString(string: word.initialCaps() + ": ", attributes: Constants.AttributeDefinition.correctWord16BoldBL)
            let definition = NSAttributedString(string: def.initialCaps() + "\n" , attributes: Constants.AttributeDefinition.definition14GR)
            
            // add lines to missedWordsList - word.wordsArray[0] is the correct word
            correctWordsAttributedTextString.append(correctWord)
            correctWordsAttributedTextString.append(definition)
            
            // apply paragraph styles to paragraph
            correctWordsAttributedTextString.addAttribute(NSParagraphStyleAttributeName, value: Constants.AttributeDefinition.paraLeft1, range: NSRange(location: 0, length: correctWordsAttributedTextString.length))
        }
    }
}

