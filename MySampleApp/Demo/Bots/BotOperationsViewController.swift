//
//  BotOperationsViewController.swift
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
import JSQMessagesViewController
import AWSCore
import AWSLex

/// Shows a list of operations possible with a bot(text converstion / voice conversation)
class BotOperationsViewController: UIViewController {
    var bot: Bot?
    var botCommandsList: [String]?
    var conversationTypes: [String]?
    
    // Description for the bot
    @IBOutlet weak var botDescription: UILabel!
    
    // Types of conversation supported with bot (text / voice)
    @IBOutlet weak var conversationTypesList: UITableView!
    
    // Intents (commands) supported by Bot
    @IBOutlet weak var botCommands: UITableView!
    
    // Label for bot intents
    @IBOutlet weak var botIntentsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conversationTypes = ["Voice to Voice Demo", "Text to Text Demo"]
        conversationTypesList.delegate = self
        conversationTypesList.dataSource = self
        botCommands.delegate = self
        botCommands.dataSource = self
        self.botDescription.text = self.bot?.botDescription
        self.botCommandsList = self.bot?.commandsHelp
        self.title = self.bot?.name
        if self.botCommandsList?.count == 0 {
            self.botCommands.isHidden = true
            self.botIntentsLabel.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? BotVoiceChatViewController {
            destinationViewController.bot = self.bot
        } else if let destinationViewController = segue.destination as? BotTextChatViewController {
            destinationViewController.botName = self.bot!.configuration.name
            destinationViewController.botAlias = self.bot!.configuration.alias
            destinationViewController.botRegion = self.bot!.configuration.region
        }
    }
}

// MARK: - UITableView Delegate

extension BotOperationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == conversationTypesList {
            if indexPath.row == 0 {
                let storyboard = UIStoryboard(name: "BotVoiceChat", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "BotVoiceChat") as? BotVoiceChatViewController
                viewController?.bot = self.bot!
                self.navigationController!.pushViewController(viewController!, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "BotTextChat", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "BotTextChat") as? BotTextChatViewController
                viewController?.botName = self.bot!.configuration.name
                viewController?.botAlias = self.bot!.configuration.alias
                viewController?.botRegion = self.bot!.configuration.region
                self.navigationController!.pushViewController(viewController!, animated: true)
            }
        }
    }
}

// MARK: - UITableView Data Source

extension BotOperationsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == botCommands {
            return self.botCommandsList!.count
        } else {
            return self.conversationTypes!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == botCommands {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommandCellIdentifier", for: indexPath)
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 14.0)
            cell.textLabel?.text = "\"\(self.botCommandsList![indexPath.row])\""
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OperationTypeCellIdentifier", for: indexPath)
            cell.textLabel?.text = self.conversationTypes![indexPath.row]
            cell.textLabel?.textColor = UIColor.jsq_messageBubbleBlue()
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
}