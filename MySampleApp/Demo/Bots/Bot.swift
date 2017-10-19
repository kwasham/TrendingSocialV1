//
//  Bot.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.19
//

import Foundation
import AWSCore

/// Represents the configuration for a Bot created with Amazon Lex.
class Bot {
    
    // Name of the bot
    var name: String
    
    // Description for the bot
    var botDescription: String
    
    // Intents (Commands) available for the bot
    var commandsHelp: [String]
    
    // Configuration for the bot
    var configuration: BotConfiguration
    
    /**
     Initializer for bot object
     
     - parameter name:          name for the bot
     - parameter description:   description for the bot
     - parameter commandsHelp:  intents (commands) availabe for the bot
     - parameter configuration: the configuration object for the bot
     
     - returns: an instance of Bot with specified parameters
     */
    init(name: String,
         description: String,
         commandsHelp: [String],
         configuration: BotConfiguration) {
        self.name = name
        self.botDescription = description
        self.commandsHelp = commandsHelp
        self.configuration = configuration
    }
}

class BotConfiguration {
    // Name of the bot
    var name: String
    
    // Alias of the bot
    var alias: String
    
    // Region where the bot is created
    var region: AWSRegionType
    
    /**
     Initializer for BotConfiguration object
     
     - parameter name:   name of the bot
     - parameter alias:  alias of the bot
     - parameter region: region where bot was created
     
     - returns: instance of BotConfiguration with specified configuration
     */
    init(name: String,
         alias: String,
         region: AWSRegionType) {
        self.name = name
        self.alias = alias
        self.region = region
    }
}
