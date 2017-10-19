//
//  BotsFactory.swift
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

/// Manages list of bots available for Demo in the sample app
class BotsFactory {
    // Returns the list of bots configured through Mobile Hub Console
    static var supportedBots: [Bot] {
        return [
            Bot(name: "BookTripMOBILEHUB",
                description: "Bot to make reservations for a visit to a city.",
                commandsHelp: [
                    "Book a car",
                    "Reserve a car",
                    "Make a car reservation",
                    "Book a hotel",
                    "Reserve a room",
                    "I want to make a hotel reservation",
                   ],

                configuration: BotConfiguration(
                    name: BookTripMOBILEHUBBotName,
                    alias: BookTripMOBILEHUBBotAlias,
                    region: BookTripMOBILEHUBBotRegion)),
        ]
    }
}
