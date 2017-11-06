//
//  JSManager.swift
//  JsPlayground
//
//  Created by Marc Attinasi on 11/2/17.
//  Copyright © 2017 ServiceNow. All rights reserved.
//

import Foundation
import JavaScriptCore

protocol PersistenceDelegate {
    func save(model: String) -> Void;
    func load() -> String;
}

class JSManager: PersistenceDelegate {

    // manage as a singleton
    //
    public static func instance() -> JSManager {
        if (_instance == nil) {
            _instance = JSManager()
        }
        return _instance!
    }
    static fileprivate var _instance: JSManager?

    //
    // wrappers around JS functions defined in the model.js file
    //
    
    public func getTitle() -> String {
        guard let f = context?.objectForKeyedSubscript("getTitle") else {
            return ""
        }
        return f.call(withArguments: nil).toString()
    }
    
    public func getModel() -> String {
        guard let f = context?.objectForKeyedSubscript("getModel") else {
            return ""
        }
        return f.call(withArguments: nil).toString()
    }
    
    public func addObject(name: Any, value: Any) {
        if let f = context?.objectForKeyedSubscript("addObject") {
            f.call(withArguments: [name, value])
        }
    }
    
    public func printModel() {
        if let f = context?.objectForKeyedSubscript("printModel") {
            f.call(withArguments: nil)
        }
    }
    
    public func addSession(owner: String) -> String? {
        if let f = context?.objectForKeyedSubscript("newSession") {
            if let session = f.call(withArguments: [owner]) {
                return session.toDictionary()?["id"] as? String
            }
        }
        return nil
    }
    
    public func getSession(sessionId: String) -> ChatSession? {
        if let f = context?.objectForKeyedSubscript("getSession") {
            if let sessionValue = f.call(withArguments: [sessionId]) {
                return ChatSession.fromJS(sessionJSValue: sessionValue)
            }
        }
        return nil
    }
    
    public func addMessage(sessionId: String, message: String) -> Bool {
        if let f = context?.objectForKeyedSubscript("addMessage") {
            let chatMessage = ChatMessage(text: message)
            if let jsChatMessage = chatMessage.toJS(context: context!) {
                if let status = f.call(withArguments: [sessionId, jsChatMessage]) {
                    return status.toBool()
                }
            }
        }
        return false
    }
    
    public func findSessionWithMessage(text: String) -> ChatSession? {
        if let f = context?.objectForKeyedSubscript("findMessage") {
            if let sessionId = f.call(withArguments: [text]).toString() {
                if let session = getSession(sessionId: sessionId) {
                    return session
                }
            }
        }
        return nil
    }
    
    //
    // PersistenceDelegate methods
    //
    
    public func save(model: String) {
        print("Saving model...")

        print(model)
    }
    
    public func load() -> String {
        print("Loading model...")
        return "{\"title\":\"loaded\",\"platform\":\"iOS\"}"
    }
    
    // iniaitlize the JS-Context (lazy, so it is only done when needed)
    //
    lazy var context: JSContext? = {
        let context = JSContext()
        
        guard let modelJSPath = Bundle.main.path(forResource: "model", ofType: "js") else {
            print("Unable to read resource files.")
            return nil
        }
        
        do {
            let modelScript = try String(contentsOfFile: modelJSPath, encoding: String.Encoding.utf8)
            _ = context?.evaluateScript(modelScript)
      
            installNativeDelegateMethods(context)
            
            initJSRuntime(context)
            
        } catch (let error) {
            print("Error while processing script file: \(error)")
        }
        
        return context
    }()
    
    fileprivate func installNativeDelegateMethods(_ context: JSContext?) {
        setupJSLogger(context)
        setupUUIDGenerator(context)
        setupPersistenceDelegate(context)
    }
    
    fileprivate func setupJSLogger(_ context:JSContext?) {
        let consoleLogger: @convention(block) (String) -> Void = { msg in
            print("JS: " + msg)
        }
        context?.setObject(consoleLogger, forKeyedSubscript: "consoleLog" as NSString)
    }
    
    fileprivate func setupUUIDGenerator(_ context:JSContext?) {
        let uuidGenerator: @convention(block) () -> String = {
            return UUID.init().uuidString
        }
        context?.setObject(uuidGenerator, forKeyedSubscript: "uuidGen" as NSString)
    }
    
    fileprivate func setupPersistenceDelegate(_ context:JSContext?) {
        let saveFunc: @convention(block) (String) -> Void = { model in
            self.save(model: model)
        }
        context?.setObject(saveFunc, forKeyedSubscript: "saveModel" as NSString)

        let loadFunc: @convention(block) () -> String = {
            return self.load()
        }
        context?.setObject(loadFunc, forKeyedSubscript: "loadModel" as NSString)
    }
    
    fileprivate func initJSRuntime(_ context:JSContext?) {
        guard let f = context?.objectForKeyedSubscript("initialize") else {
            return
        }
        f.call(withArguments: nil)
    }
    
    fileprivate func deinitJSRuntime(_ context:JSContext?) {
        guard let f = context?.objectForKeyedSubscript("deinitialize") else {
            return
        }
        f.call(withArguments: nil)
    }
}
