
//  ParseLoginHelper.swift

import Foundation
import Parse
import ParseUI

typealias ParseLoginHelperCallback = (PFUser?, NSError?) -> Void

/**
 This class implements the 'PFLogInViewControllerDelegate' protocol. After a successfull login
 it will call the callback function and provide a 'PFUser' object.
 */
class ParseLoginHelper : NSObject {
    static let errorDomain = "com.makeschool.parseloginhelpererrordomain"
    static let usernameNotFoundErrorCode = 1
    static let usernameNotFoundLocalizedDescription = "Could not retrieve Facebook username"
    let callback: ParseLoginHelperCallback
    
    init(callback: ParseLoginHelperCallback) {
        self.callback = callback
    }
}

extension ParseLoginHelper : PFLogInViewControllerDelegate{
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
                self.callback(nil, error)
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        
            self.callback(user, nil)
        
    }
    
}

extension ParseLoginHelper : PFSignUpViewControllerDelegate {
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(false, completion: nil)
        self.callback(user, nil)
    }
    
}