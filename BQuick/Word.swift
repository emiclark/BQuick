//
//  Word.swift
//  BQuick
//
//  Created by Emiko Clark on 6/10/17.
//  Copyright © 2017 Emiko Clark. All rights reserved.
//

import UIKit
import SwiftyJSON

class Word : NSObject {

    var wordsArray: [String] = []
    var definition: String = ""
    
    init(wordsArray: [String], definition: String) {
        self.wordsArray = wordsArray
        self.definition = definition
    }
}

