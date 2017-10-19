//
//  ContentDeliveryViewController.swift
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

import UIKit
import AWSMobileHubContentManager
import AVKit
import AVFoundation

class ContentDeliveryViewController: UITableViewController {
    
    @IBOutlet weak var cacheLimitLabel: UILabel!
    @IBOutlet weak var currentCacheSizeLabel: UILabel!
    @IBOutlet weak var availableCacheSizeLabel: UILabel!
    @IBOutlet weak var pinnedCacheSizeLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    
    fileprivate var prefix: String!
    fileprivate var marker: String?
    fileprivate var contents: [AWSContent]?
    fileprivate var didLoadAllContents: Bool!
    
    fileprivate var manager: AWSContentManager!
    fileprivate let dateFormatter: DateFormatter = DateFormatter()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = AWSContentManager.default()
        
        // Sets up the UIs.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ContentDeliveryViewController.showContentManagerActionOptions(_:)))
        
        // Sets up the date formatter.
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        didLoadAllContents = false
        updateUserInterface()
        loadMoreContents()
    }
    
    fileprivate func updateUserInterface() {
        cacheLimitLabel.text = manager.maxCacheSize.aws_stringFromByteCount()
        currentCacheSizeLabel.text = manager.cachedUsedSize.aws_stringFromByteCount()
        availableCacheSizeLabel.text = (manager.maxCacheSize - manager.cachedUsedSize).aws_stringFromByteCount()
        pinnedCacheSizeLabel.text = manager.pinnedSize.aws_stringFromByteCount()
        
        if let prefix = self.prefix {
            pathLabel.text = prefix
        } else {
            pathLabel.text = "/"
        }
        tableView.reloadData()
    }
    
    // MARK: - Content Manager user action methods
    
    func showContentManagerActionOptions(_ sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let refreshAction = UIAlertAction(title: "Refresh", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.refreshContents()
            })
        alertController.addAction(refreshAction)
        let downloadObjectsAction = UIAlertAction(title: "Download Recent", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.downloadObjectsToFillCache()
            })
        alertController.addAction(downloadObjectsAction)
        let changeLimitAction = UIAlertAction(title: "Set Cache Size", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.showDiskLimitOptions()
            })
        alertController.addAction(changeLimitAction)
        let removeAllObjectsAction = UIAlertAction(title: "Clear Cache", style: .destructive, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.manager.clearCache()
            self.updateUserInterface()
            })
        alertController.addAction(removeAllObjectsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func refreshContents() {
        marker = nil
        loadMoreContents()
    }
    
    fileprivate func loadMoreContents() {
        manager.listAvailableContents(withPrefix: prefix, marker: marker) {[weak self] (contents: [AWSContent]?, nextMarker: String?, error: Error?) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to load the list of contents.", cancelButtonTitle: "OK")
                print("Failed to load the list of contents. \(error)")
            }
            if let contents = contents, contents.count > 0 {
                strongSelf.contents = contents
                if let nextMarker = nextMarker, !nextMarker.isEmpty{
                    strongSelf.didLoadAllContents = false
                } else {
                    strongSelf.didLoadAllContents = true
                }
                strongSelf.marker = nextMarker
            }
            strongSelf.updateUserInterface()
        }
    }
    
    fileprivate func showDiskLimitOptions() {
        let alertController = UIAlertController(title: "Disk Cache Size", message: nil, preferredStyle: .actionSheet)
        for number: Int in [1, 5, 20, 50, 100] {
            let byteLimitOptionAction = UIAlertAction(title: "\(number) MB", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                self.manager.maxCacheSize = UInt(number) * 1024 * 1024
                self.updateUserInterface()
                })
            alertController.addAction(byteLimitOptionAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func downloadObjectsToFillCache() {
        manager.listRecentContents(withPrefix: prefix) {[weak self] (contents: [AWSContent]?, error: Error?) in
            guard let strongSelf = self else { return }
            if let downloadResult: [AWSContent] = contents {
                for content: AWSContent in downloadResult {
                    if !content.isCached && !content.isDirectory {
                        strongSelf.downloadContent(content, pinOnCompletion: false)
                    }
                }
            }
        }
    }
    
    // MARK: - Content user action methods
    
    fileprivate func showActionOptionsForContent(_ rect: CGRect, content: AWSContent) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if alertController.popoverPresentationController != nil {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: rect.midX, y: rect.midY, width: 1.0, height: 1.0)
        }

        if content.isCached {
            let openAction = UIAlertAction(title: "Open", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                DispatchQueue.main.async {
                    self.openContent(content)
                }
                })
            alertController.addAction(openAction)
        }
        
        // Allow opening of remote files natively or in browser based on their type.
        let openRemoteAction = UIAlertAction(title: "Open Remote", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.openRemoteContent(content)
            })
        alertController.addAction(openRemoteAction)
        
        
        // If the content hasn't been downloaded, and it's larger than the limit of the cache,
        // we don't allow downloading the contentn.
        if content.knownRemoteByteCount + 4 * 1024 < manager.maxCacheSize {
            // 4 KB is for local metadata.
            var title: String = "Download"
            if let downloadedDate = content.downloadedDate, let knownRemoteLastModifiedDate = content.knownRemoteLastModifiedDate, knownRemoteLastModifiedDate.compare(downloadedDate) == .orderedDescending {
                title = "Download Latest Version"
            }
            
            let downloadAction = UIAlertAction(title: title, style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                self.downloadContent(content, pinOnCompletion: false)
                })
            alertController.addAction(downloadAction)
        }
        
        let downloadAndPinAction = UIAlertAction(title: "Download & Pin", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
            self.downloadContent(content, pinOnCompletion: true)
            })
        alertController.addAction(downloadAndPinAction)
        
        if content.isCached {
            if content.isPinned {
                let unpinAction = UIAlertAction(title: "Unpin", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                    content.unPin()
                    self.updateUserInterface()
                    })
                alertController.addAction(unpinAction)
            } else {
                let pinAction = UIAlertAction(title: "Pin", style: .default, handler: {[unowned self](action: UIAlertAction) -> Void in
                    content.pin()
                    self.updateUserInterface()
                    })
                alertController.addAction(pinAction)
            }
            let removeAction = UIAlertAction(title: "Delete Local Copy", style: .destructive, handler: {[unowned self](action: UIAlertAction) -> Void in
                content.removeLocal()
                self.updateUserInterface()
                })
            alertController.addAction(removeAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func downloadContent(_ content: AWSContent, pinOnCompletion: Bool) {
        content.download( with: .ifNewerExists, pinOnCompletion: pinOnCompletion, progressBlock: {[weak self](content: AWSContent?, progress: Progress?) -> Void in
            guard let strongSelf = self else { return }
            if strongSelf.contents!.contains( where: {$0 == content}) {
                let row = strongSelf.contents!.index(where: {$0 == content})!
                let indexPath = IndexPath(row: row, section: 0)
                strongSelf.tableView.reloadRows(at: [indexPath], with: .none)
            }
            }, completionHandler: {[weak self](content: AWSContent?, data: Data?, error: Error?) -> Void in
                guard let strongSelf = self else { return }
                if let downloadError = error as NSError? {
                    print("Failed to download a content from a server.\(downloadError)")
                    strongSelf.showSimpleAlertWithTitle("Error", message: "Failed to download a content from a server.", cancelButtonTitle: "OK")
                }
                strongSelf.updateUserInterface()
            })
    }
    
    fileprivate func openContent(_ content: AWSContent) {
        if content.isAudioVideo() { // Video and sound files
            let directories: [AnyObject] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [AnyObject]
            let cacheDirectoryPath = directories.first as! String
            let movieURL = URL(fileURLWithPath: "\(cacheDirectoryPath)/\(content.key.getLastPathComponent())")
            try? content.cachedData.write(to: movieURL, options: [.atomic])
            
            let player = AVPlayer(url: movieURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        } else if content.isImage() {
            // Image files
            let storyboard = UIStoryboard(name: "ContentDelivery", bundle: nil)
            let imageViewController = storyboard.instantiateViewController(withIdentifier: "ContentDeliveryImageViewController") as! ContentDeliveryImageViewController
            imageViewController.image = UIImage(data: content.cachedData)
            imageViewController.title = content.key
            navigationController?.pushViewController(imageViewController, animated: true)
        } else {
            showSimpleAlertWithTitle("Sorry!", message: "We can only open image, video, and sound files.", cancelButtonTitle: "OK")
        }
    }
    
    fileprivate func openRemoteContent(_ content: AWSContent) {
        content.getRemoteFileURL { (url: URL?, error: Error?) in
            guard let url = url else {
                print("Error getting URL for file. \(error)")
                return
            }
            if content.isAudioVideo() { // Open Audio and Video files natively in app.
                let player = AVPlayer(url: url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            } else { // Open other file types like PDF in web browser.
                let storyboard = UIStoryboard(name: "ContentDelivery", bundle: nil)
                let webViewController = storyboard.instantiateViewController(withIdentifier: "ContentDeliveryWebViewController") as! ContentDeliveryWebViewController
                webViewController.url = url
                webViewController.title = content.key
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contents = self.contents {
            return contents.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentDeliveryCell", for: indexPath) as! ContentDeliveryCell
        let content = contents![indexPath.row]
        cell.prefix = prefix
        cell.content = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let contents = self.contents {
            if indexPath.row == contents.count - 1 {
                if (!didLoadAllContents) {
                    loadMoreContents()
                }
            }
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let content = self.contents![indexPath.row]
        if content.isDirectory {
            let storyboard = UIStoryboard(name: "ContentDelivery", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ContentDeliveryViewController") as! ContentDeliveryViewController
            viewController.prefix = content.key
            navigationController!.pushViewController(viewController, animated: true)
        } else {
            let rowRect = tableView.rectForRow(at: indexPath)
            showActionOptionsForContent(rowRect, content: content)
        }
    }
}

class ContentDeliveryCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var keepImageView: UIImageView!
    @IBOutlet weak var downloadedImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var prefix: String?
    var content: AWSContent! {
        didSet{
            var displayFilename: String = content.key
            if let prefix: String = self.prefix {
                displayFilename = displayFilename.substring(from: prefix.endIndex)
            }
            
            fileNameLabel.text = displayFilename
            downloadedImageView.isHidden = !content.isCached
            keepImageView.isHidden = !content.isPinned
            var contentByteCount: UInt = content.fileSize
            if contentByteCount == 0 {
                contentByteCount = content.knownRemoteByteCount
            }
            
            if self.content.isDirectory {
                detailLabel.text = "This is a folder"
                accessoryType = .disclosureIndicator
            } else {
                detailLabel.text = contentByteCount.aws_stringFromByteCount()
                accessoryType = .none
            }
            
            if let downloadedDate = content.downloadedDate, let knownRemoteLastModifiedDate = content.knownRemoteLastModifiedDate, knownRemoteLastModifiedDate.compare(downloadedDate) == .orderedDescending {
                detailLabel.text = "\(detailLabel.text!) - New Version Available"
                detailLabel.textColor = UIColor.blue
            } else {
                detailLabel.textColor = UIColor.black
            }
            
            if content.status == .running {
                progressView.progress = Float(content.progress.fractionCompleted)
                progressView.isHidden = false
            } else {
                progressView.isHidden = true
            }
        }
    }
}

class ContentDeliveryImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = image
    }
}

class ContentDeliveryWebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var url: URL!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.delegate = self
        webView.dataDetectorTypes = UIDataDetectorTypes()
        webView.scalesPageToFit = true
        webView.loadRequest(URLRequest(url: url))
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("The URL content failed to load \(error)")
        webView.loadHTMLString("<html><body><h1>Cannot Open the content of the URL.</h1></body></html>", baseURL: nil)
    }
}

// MARK: - Utility

extension ContentDeliveryViewController {
    fileprivate func showSimpleAlertWithTitle(_ title: String, message: String, cancelButtonTitle cancelTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension AWSContent {
    fileprivate func isAudioVideo() -> Bool {
        let lowerCaseKey = self.key.lowercased()
        return lowerCaseKey.hasSuffix(".mov")
            || lowerCaseKey.hasSuffix(".mp4")
            || lowerCaseKey.hasSuffix(".mpv")
            || lowerCaseKey.hasSuffix(".3gp")
            || lowerCaseKey.hasSuffix(".mpeg")
            || lowerCaseKey.hasSuffix(".aac")
            || lowerCaseKey.hasSuffix(".mp3")
    }
    
    fileprivate func isImage() -> Bool {
        let lowerCaseKey = self.key.lowercased()
        return lowerCaseKey.hasSuffix(".jpg")
            || lowerCaseKey.hasSuffix(".png")
            || lowerCaseKey.hasSuffix(".jpeg")
    }
}

extension UInt {
    fileprivate func aws_stringFromByteCount() -> String {
        if self < 1024 {
            return "\(self) B"
        }
        if self < 1024 * 1024 {
            return "\(self / 1024) KB"
        }
        if self < 1024 * 1024 * 1024 {
            return "\(self / 1024 / 1024) MB"
        }
        return "\(self / 1024 / 1024 / 1024) GB"
    }
}

extension String {
    fileprivate func getLastPathComponent() -> String {
        let nsstringValue: NSString = self as NSString
        return nsstringValue.lastPathComponent
    }
}
