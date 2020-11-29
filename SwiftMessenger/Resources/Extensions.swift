//
//  Extensions.swift
//  SwiftMessenger
//
//  Created by AlbertStanley on 20/11/20.
//

import UIKit

extension UIView {
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}

extension Notification.Name {
    static let didGoogleLoginNotification = Notification.Name("didGoogleLoginNotification")
}

/// User defaults string key
extension String {
    static let userEmailKey = "user_email_key"
    static let userNameKey = "user_name_key"
}
