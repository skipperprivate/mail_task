//
//  Tweet.swift
//  TaskApp
//
//  Created by Олег Максименко on 23.08.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

import Foundation

class Tweet{
    
    var author: String?
    var tweet_text: String?
    
    init(author: String, tweet_text: String){
        
        self.author = author
        self.tweet_text = tweet_text
        
    }
    
    
}
