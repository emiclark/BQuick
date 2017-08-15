//
//  GameViewController.swift
//  BQuick
//
//  Created by Emiko Clark on 5/23/17
//  Copyright © 2016 Emiko Clark. All rights reserved.
//


import UIKit

let gameTime = 45
let maxNumberOfWordsInWordsArray = 3 // wordsArray: correctWord + 2 incorrect words
let myBlueColor = UIColor(red: 10/255, green: 100/255, blue: 150/255, alpha: 1)

class GameViewController : UIViewController {

    // MARK: - Properties

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var wordDisplayedLabel: PaddedLabel!
    @IBOutlet weak var rightGestArrow: UIImageView!
    @IBOutlet weak var leftGestArrow: UIImageView!
    @IBOutlet weak var XLabel: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var beeImageView: UIImageView!

    var currentGameTime = gameTime
    var wordFontSize = 40
    var correctWord: String?
    var timer : Timer?
    
    var selectedIncorrectWord: String = ""
    
    let dao = DAO.sharedInstance
    
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add gradient bkg
        addGradientBackground()
        
        //setup left and right SwipeGestureRecognizers and functions
        // add right gesture for view
        let viewRightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        viewRightSwipe.direction = .right
        self.view.addGestureRecognizer(viewRightSwipe)

        // add right gesture for next word label
        let labelRightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        labelRightSwipe.direction = .right
        wordDisplayedLabel.addGestureRecognizer(labelRightSwipe)
        
        // add left gesture for view
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)

        // add left gesture for next word label
        let labelLeftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        labelLeftSwipe.direction = .left
        wordDisplayedLabel.addGestureRecognizer(labelLeftSwipe)
        
        // show instructions at startup
        instructionsTextView.isHidden = false
        showInstructions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reset bee animation
        beeImageView.image = #imageLiteral(resourceName: "Icon")
        beeImageView.contentMode = .center
        
        // set audio ON/OFF
        if(self.dao.soundON) == true {
            dao.backgroundMusic.play()
            audioButton.setImage(#imageLiteral(resourceName: "audioON"), for: .normal)
        } else  {
            audioButton.setImage(#imageLiteral(resourceName: "audioOFF"), for: .normal)
            dao.backgroundMusic.pause()
        }
        resetGame()
        
    }
    
    // MARK: - Play Game Methods

    @IBAction func playButtonTapped(_ sender: UIButton) {
        // begin game
        resetGame()
        dao.resetGameOverWordsList()
        instructionsTextView.isHidden = true
        playButton.isHidden = true
        startTimer()
        dao.playGame = true
        getNextWord()
        
        // start bee animation
        beeImageView.contentMode = .center
        beeImageView.loadGif(name: "beeAnimation3")
    }
    
    // MARK: - Reset Game

    func resetGame(){
        
        // reset for a new game
        currentGameTime = gameTime
        wordDisplayedLabel.alpha = 0.0
        XLabel.alpha = 0.0
        rightGestArrow.alpha = 0.0
        leftGestArrow.alpha = 0.0
        scoreLabel.text = "Score: 0"
        timerLabel.text = "Secs: \(currentGameTime)"
        playButton.isHidden = false
        dao.playGame = false

        dao.guessedCorrect = false
        dao.didSwipeRight = false
        dao.didSwipeLeft = false
        timer?.invalidate()
        dao.scored = 0
        dao.totalNumWordsDisplayed = 1
    }
    
    // MARK: - Timer Methods

    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true);
    }

    func updateTimer(sender : Timer) {
        // update timer label for the game
        if currentGameTime > 0 {
            currentGameTime -= 1
            timerLabel.text = "Sec: \(currentGameTime)"
        } else {
            // game over
            gameOver()
        }
    }

    
    
    // MARK: - Swipe Gesture Methods


    func handleLeftSwipe() {
        // swipe word left off screen
        if (dao.playGame == true) {
            dao.didSwipeLeft = false
            UIView.animate(withDuration: 0.25, animations: {
                self.wordDisplayedLabel.frame.origin = CGPoint(x: -750, y: self.wordDisplayedLabel.frame.origin.y)
                self.dao.didSwipeLeft = true
                self.dao.didSwipeRight = false
            }) { (_) in
                self.checkAnswer(swipe: self.dao.didSwipeLeft)
            }
        }
    }
    
    func handleRightSwipe() {
        // swipe word right off screen
        if (dao.playGame == true) {
            self.dao.didSwipeRight = false
            UIView.animate(withDuration: 0.25, animations: {
                self.wordDisplayedLabel.frame.origin = CGPoint(x: 750, y: self.wordDisplayedLabel.frame.origin.y)
                self.dao.didSwipeRight = true
                self.dao.didSwipeLeft = false
            }) { (_) in
                self.checkAnswer(swipe: self.dao.didSwipeRight)
            }
        }
    }
    
    
    // MARK: - Get and Show Next Word Methods
    
    func getNextWord() {
        // randomly get unique word from wordsArray to display
        
        var newWordWasNotPlayed = false
        
        while newWordWasNotPlayed == false {
            
            // reset dictionary if all words are displayed
            if (dao.wordsDisplayedDict.count == dao.totalWords) {
                dao.wordsDisplayedDict.removeAll()
            }
            
            // pick a random word from the mainWordsArray
            let index1 = Int(arc4random_uniform(UInt32(dao.mainWordsArray.count)))
            dao.nextWord = dao.mainWordsArray[index1]
            correctWord = dao.nextWord?.wordsArray[0]
            
            // pick a random word in the wordArray of the selected word object - wordArray[0] contains the correct word, wordArray[1,2,3] has incorrect spelling of the word
            let index2 = Int(arc4random_uniform(UInt32(dao.mainWordsArray[index1].wordsArray.count)))
            
            
            // check if word has been displayed
            if dao.wordsDisplayedDict[(dao.nextWord?.wordsArray[index2])!] == nil {
                // use new nextWord - has not been displayed
                dao.wordDisplayed = (dao.nextWord?.wordsArray[index2])!
                dao.wordsDisplayedDict[dao.wordDisplayed] = true
                correctWord = dao.nextWord?.wordsArray[0]
                newWordWasNotPlayed = true
            }
        }
        showNextWord(wordDisplayed: dao.wordDisplayed)
    }
    
    
    func showNextWord (wordDisplayed: String) {
        
        //animate nextWord to drop from the top to middle with a slight bounce
        wordDisplayedLabel.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.wordDisplayedLabel.alpha = 1.0
        }
        
        wordDisplayedLabel.text = wordDisplayed
        
        // adjust wordDisplayed frame to size of word
        let size =  (wordDisplayed as NSString).size(attributes: [NSFontAttributeName :
            UIFont.init(name: "Chalkboard SE", size: 40) ?? UIFont.systemFont(ofSize: 40)])
        
        wordDisplayedLabel.frame = CGRect(x: 0, y: 0, width: size.width + 20, height: size.height + 20)
        wordDisplayedLabel.textAlignment = .center
        
        // Starting position of the label
        self.wordDisplayedLabel.center = CGPoint(x: 200, y: -50)
        
        //Adding the nextWord to the Subview to see it
        view.addSubview(self.wordDisplayedLabel)
        
        //Animation options. Play  around with it.
        UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.560, initialSpringVelocity: 0.50, options: [.allowUserInteraction, .curveLinear], animations: {
            
            // Set ending position of the next word
            self.wordDisplayedLabel.center = CGPoint(x: 200, y:400 )
        }, completion: nil)
    }
    
    // MARK: - Check Guess Methods

    
    func checkAnswer(swipe: Bool) {
        
        // check if player guessed if word the displayed was correctly spelled or misspelled based on the swipe
        
        dao.guessedCorrect = false
        
        if (swipe == dao.didSwipeRight) {
            
            if (dao.wordDisplayed == correctWord) {
                // guessed right: swiped right + correct word
                // correct: swiped right on correct word. show green arrow and check mark
                rightGestArrow.image = UIImage(named: "rightGreenArrow.png")
                self.rightGestArrow.alpha = 1
                self.XLabel.image = UIImage(named:"correct.png")
                self.XLabel.alpha = 1
                UIView.animate(withDuration: 1.0 , animations: {
                    self.rightGestArrow.alpha = 0
                    self.XLabel.alpha = 0
                })
                // check if the word is in either guessedRightDict or guessedWrongDict and add to corresponding word list
                if (dao.guessedWrongDict[correctWord!] == nil && dao.guessedRightDict[correctWord!] == nil) {
                    dao.guessedRightDict[correctWord!] = dao.nextWord?.definition
                    
                }
                dao.guessedCorrect = true
            }
                
            else {
                // guessed wrong: swiped right on incorrect word. show pink arrow & XLabel
                rightGestArrow.image = UIImage(named: "rightPinkArrow.png")
                self.rightGestArrow.alpha = 1
                self.XLabel.image = UIImage(named: "X2.png")
                self.XLabel.alpha = 1
                UIView.animate(withDuration: 1.0, animations: {
                    self.rightGestArrow.alpha = 0
                    self.XLabel.alpha = 0
                })
                
                // check if the word is in either guessedRightDict or guessedWrongDict and add to corresponding word list
                if (dao.guessedWrongDict[correctWord!] == nil && dao.guessedRightDict[correctWord!] == nil) {
                    dao.guessedWrongDict[correctWord!] = dao.nextWord?.definition
                }
            }
            

        } else if (swipe == dao.didSwipeLeft) {
            
            if (dao.wordDisplayed == correctWord) {
                
                // guessed wrong: swiped Left on a correct word. show pink arrow & XLabel
                leftGestArrow.image = UIImage(named: "leftPinkArrow.png")
                self.leftGestArrow.alpha = 1
                self.XLabel.image = UIImage(named: "X2.png")
                self.XLabel.alpha = 1
                UIView.animate(withDuration: 1.0, animations: {
                    self.leftGestArrow.alpha = 0
                    self.XLabel.alpha = 0
                })

                // check if the word is in either guessedRightDict or guessedWrongDict and add to corresponding word list
                if (dao.guessedWrongDict[correctWord!] == nil && dao.guessedRightDict[correctWord!] == nil) {
                    dao.guessedWrongDict[correctWord!] = dao.nextWord?.definition
                }
            }
        
            else  {
                // guessed correct: swiped Left on incorrect word. show green arrow and check mark
                leftGestArrow.image = UIImage(named: "leftGreenArrow.png")
                self.leftGestArrow.alpha = 1
                self.XLabel.image = UIImage(named: "correct.png")
                self.XLabel.alpha = 1
                UIView.animate(withDuration:0.4, animations: {
                    self.leftGestArrow.alpha = 0
                    self.XLabel.alpha = 0
                })
                
                // check if the word is in either guessedRightDict or guessedWrongDict and add to corresponding word list
                if (dao.guessedRightDict[correctWord!] == nil && dao.guessedWrongDict[correctWord!] == nil) {
                    dao.guessedRightDict[correctWord!] = dao.nextWord?.definition
                    
                }
                dao.guessedCorrect = true
            }
        }
        
        updateScore()
    }
    
    // MARK: - Update Score
    
    func updateScore() {
        if(dao.guessedCorrect == true) {
            dao.scored += 1
        }
        dao.totalNumWordsDisplayed += 1
        scoreLabel.text = "Score: \(dao.scored)"
        getNextWord()

    }
    
    
    // MARK: - Game Over Methods

    func gameOver() {
        // prepare output to show player the score and words list
        print("gameOver")
        timer?.invalidate()
        self.timer = nil
        dao.totalNumWordsDisplayed = dao.totalNumWordsDisplayed
        
        dao.createScoreOutput()

        // push to score view controller
        let gameOverVC = self.storyboard!.instantiateViewController(withIdentifier: "GameOver") as! GameOverViewController
        gameOverVC.scoreOutput = dao.finalOutput
        self.present(gameOverVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Misc Methods
    
    func showInstructions() {
        // show instructions on how to play when the app first launches
        let paraJust = NSMutableParagraphStyle()
        paraJust.alignment = .center
        paraJust.lineSpacing = 1
        paraJust.maximumLineHeight = 22
        
        // set attributes
        let header22BoldBR: [String: Any] = [
            NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 22) ?? UIFont.boldSystemFont(ofSize: 22),
            NSForegroundColorAttributeName: UIColor.brown,
            NSParagraphStyleAttributeName: paraJust
        ]
        
        instructionsTextView.layer.masksToBounds = true
        instructionsTextView.layer.cornerRadius = 10
        
        let instructionsStr = "\n\n Swipe RIGHT\n if word is spelled\n CORRECTLY,\n\nSwipe LEFT\nif word is\nMISSPELLED."
        let instructionsWithAttributes = NSAttributedString(string: instructionsStr, attributes: header22BoldBR)
        
        instructionsTextView.attributedText = instructionsWithAttributes
    }
    
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        // toggles the audio on and off
        if(self.dao.soundON) {
            audioButton.setImage(#imageLiteral(resourceName: "audioOFF"), for: .normal)
            dao.backgroundMusic.pause()
            dao.soundON = false
            
        } else  {
            audioButton.setImage(#imageLiteral(resourceName: "audioON"), for: .normal)
            dao.backgroundMusic.play()
            dao.soundON = true
        }
    }
    

    
    func addGradientBackground() {
        
        //display gradient background for view
        let gradientLayer = CAGradientLayer()
        
        //set gradientLayer to the size of the view.frame (full screen)
        gradientLayer.frame = self.view.frame
        
        //set gradient colors for top and bottom
        let topColor = UIColor(red: 73.0/255.0, green: 223.0/255.0, blue: 185.0/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 36.0/255.0, green: 115/255.0, blue: 192.0/255, alpha: 1.0)
        
        //add colors to array to gradiate between
        let gradientColorsArray = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.colors = gradientColorsArray
        
        //set the location of where colors should gradiate between
        gradientLayer.locations = [0.0, 1.0]

        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension String {
    func initialCaps() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func initialCaps() {
        self = self.initialCaps()
    }
}


