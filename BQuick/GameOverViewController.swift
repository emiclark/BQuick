//
//  GameOverViewController.swift
//  BQuick
//
//  Created by Emiko Clark on 5/24/17.
//  Copyright © 2017 Emiko Clark. All rights reserved.
//

import UIKit


class GameOverViewController: UIViewController {
    var score = NSMutableAttributedString()
    var scoreOutput = NSMutableAttributedString()
    var dao = DAO.sharedInstance
    

    @IBOutlet weak var scoreOutputTextView: UITextView!
    @IBOutlet weak var audioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreOutputTextView.attributedText = scoreOutput

    }
    
    override func viewWillLayoutSubviews() {
        if (dao.soundON == true) {
            self.audioButton.setImage(#imageLiteral(resourceName: "audioON"), for: .normal)
        } else {
            self.audioButton.setImage(#imageLiteral(resourceName: "audioOFF"), for: .normal)
        }
        
        self.scoreOutputTextView.setContentOffset(.zero, animated: false)
        
    }

    @IBAction func audioButtonTapped(_ sender: UIButton) {
        // toggles audio on and off
        if(self.dao.soundON) {
            audioButton.setImage(#imageLiteral(resourceName: "audioOFF"), for: .normal)
            self.dao.backgroundMusic.pause()
            self.dao.soundON = false
            
        } else  {
            self.audioButton.setImage(#imageLiteral(resourceName: "audioON"), for: .normal)
            self.dao.backgroundMusic.play()
            self.dao.soundON = true
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func replayButtonTapped(_ sender: UIButton) {
        // allows player to play the game again
        dismiss(animated: true, completion: nil)
    }

}
