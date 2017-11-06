//
//  ChatModel.swift
//  JsPlayground
//
//  Created by Marc Attinasi on 11/6/17.
//  Copyright © 2017 ServiceNow. All rights reserved.
//

import Foundation
import JavaScriptCore

class ChatSession {
    var id: String
    var owner: String
    var timeStamp: String
    var messages: Array<ChatMessage>
    
    init(owner: String) {
        self.id = UUID.init().uuidString
        self.owner = owner
        self.timeStamp = Date().description
        self.messages = Array<ChatMessage>()
    }
    
    public func searchMessage(searchText: String) -> Int {
        var index = -1
        
        for message in messages {
            if message.text.contains(searchText) {
                return index+1;
            }
            index += 1
        }
        
        return index
    }
    
    class func fromJS(sessionJSValue: JSValue) -> ChatSession? {
        if let sessionDictionary = sessionJSValue.toDictionary() {
            if let owner = sessionDictionary["owner"] as? String {
                let session = ChatSession(owner: owner)
                session.id = sessionDictionary["id"] as! String
                session.timeStamp = sessionDictionary["timeStamp"] as! String
                session.messages = getMessages(messagesArray: sessionDictionary["messages"] as! Array<Any>)
                
                return session
            }
        }
        return nil
    }
    
    class func getMessages(messagesArray: Array<Any>) -> Array<ChatMessage> {
        var result = Array<ChatMessage>()
        
        for message in messagesArray {
            if let messageDictionary = message as? NSDictionary {
                result.append(ChatMessage(messageDictionary: messageDictionary))
            }
        }
        
        return result
    }
}

class ChatMessage {
    var id: String
    var timeStamp: String
    var text: String
    
    init(text: String) {
        self.id = UUID.init().uuidString
        self.timeStamp = Date().description
        self.text = text
    }
    
    init(messageDictionary: NSDictionary) {
        self.id = messageDictionary["id"] as! String
        self.timeStamp = messageDictionary["timeStamp"] as! String
        self.text = messageDictionary["text"] as! String
    }
    
    public func toJS(context: JSContext) -> JSValue? {
        if let jsobj =  JSValue(newObjectIn: context) {
            jsobj.setValue(self.id, forProperty: "id")
            jsobj.setValue(self.timeStamp, forProperty: "timeStamp")
            jsobj.setValue(self.text, forProperty: "text")
            return jsobj
        }
        return nil
    }
}


// Alternatively, the native types can be mapped to JS directly, however the class definition has to be
// in Objective-C and the exported fields have to be registered with the JS runtime externally
//  good example here: http://nshipster.com/javascriptcore/
//
//@objc protocol ChatSessionJSExports: JSExport {
//    var id: String { get set }
//    var owner: String { get set }
//    var timeStamp: String { get set }
//    var messages: Array<ChatMessage> { get set }
//
//    static func sessionWith(owner: String) -> ChatSession
//}
//
//class ChatSession: NSObject, ChatSessionJSExports {
//    dynamic var id: String
//    dynamic var owner: String
//    dynamic var timeStamp: String
//    dynamic var messages: Array<ChatMessage>
//
//    init(owner: String) {
//        self.id = UUID.init().uuidString
//        self.owner = owner
//        self.timeStamp = Date().description
//        self.messages = Array<ChatMessage>()
//
//        super.init()
//    }
//
//    class func sessionWith(owner: String) -> ChatSession {
//        return ChatSession(owner: owner)
//    }
//}

//@objc protocol ChatMessageJSExports: JSExport {
//    var id: String { get set }
//    var timeStamp: String { get set }
//    var text: String { get set }
//
//    static func messageWithText(text: String) -> ChatMessage
//}
//
//class ChatMessage: NSObject, ChatMessageJSExports {
//    dynamic var id: String
//    dynamic var timeStamp: String
//    dynamic var text: String
//
//    init(text: String) {
//        self.id = UUID.init().uuidString
//        self.timeStamp = Date().description
//        self.text = text
//    }
//
//    init(messageDictionary: NSDictionary) {
//        self.id = messageDictionary["id"] as! String
//        self.timeStamp = messageDictionary["timeStamp"] as! String
//        self.text = messageDictionary["text"] as! String
//    }
//
//    public func toJS(context: JSContext) -> JSValue? {
//        if let jsobj =  JSValue(newObjectIn: context) {
//            jsobj.setValue(self.id, forProperty: "id")
//            jsobj.setValue(self.timeStamp, forProperty: "timeStamp")
//            jsobj.setValue(self.text, forProperty: "text")
//            return jsobj
//        }
//        return nil
//    }
//
//    class func messageWithText(text: String) -> ChatMessage {
//        return ChatMessage(text: text)
//    }
//}

