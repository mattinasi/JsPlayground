'use strict';

var index = 0;

var modelRoot = {};

var initialize = function() {
    let savedModel = loadModel();
    if (savedModel) {
        modelRoot = JSON.parse(savedModel);
    }
};

var deinitialize = function() {
    let modelJSON = JSON.stringify(modelRoot);
    savedModel(modelJSON);
};

var getTitle = function() {
    return "model script " + index++;
};

var addObject = function(name, value) {
    modelRoot[name] = value;
};

var getObject = function(name) {
    return modelRoot[name];
};

var getModel = function() {
    return JSON.stringify(modelRoot, null, 4);
};

var printModel = function() {
    consoleLog(getModel())
};


var newSession = function(sessionOwner) {
    let uuid = uuidGen();
    let session = {
        id : uuid,
    timeStamp: Date.now().toString(),
    owner: sessionOwner,
    messages: []
    };
    
    let sessions = getSessions();
    sessions.push(session);
    
    return session;
};

var getSession = function(sessionId) {
    let sessions = getSessions();
    
    for (var index = 0; index < sessions.length; index++) {
        let s = sessions[index];
        if(s.id === sessionId) {
            return s;
        }
    }
    return null;
};

var findMessage = function(searchText) {
    let sessions = getSessions();
    
    for (var index = 0; index < sessions.length; index++) {
        let s = sessions[index];
        if (sessionHasMessage(s, searchText)) {
            return s.id;
        }
    }
    return null;
};

var sessionHasMessage = function(session, searchText) {
    let messages = session.messages;
    
    for (var index = 0; index < messages.length; index++) {
        let message = messages[index];
        if(message.text.includes(searchText)) {
            return true;
        }
    }
    return false;
};

var addMessage = function(sessionId, message) {
    let session = getSession(sessionId);
    if (session) {
        session.messages.push(message);
        return true;
    }
    return false;
};

var getSessions = function() {
    if(!modelRoot["sessions"]) {
        modelRoot["sessions"] = [];
    }
    return modelRoot["sessions"];
};

