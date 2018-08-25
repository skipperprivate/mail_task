import Foundation
import UIKit

class Tweet{
    
    var author: String
    var tweet_text: String
    var profile_image: UIImage
    var image_url: String
    
    init(author: String, tweet_text: String, url: String){
        
        self.author = author
        self.tweet_text = tweet_text
        self.image_url = url
        self.profile_image = UIImage()
        
    }
    
    
}
