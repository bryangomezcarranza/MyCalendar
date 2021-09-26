//
//  SettingsTableViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/13/21.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsBarColor()
        tableView.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 100)
       

    }
    //MARK: - Private Functions
    private func settingsBarColor() {
        navigationController?.navigationBar.clipsToBounds = true
        navigationController?.navigationBar.contentMode = .scaleAspectFill
        navigationController?.navigationBar.backgroundColor = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 100)
    }
    private func shareSheetTapped() {
        let textToShare = "Keep track of your events and task with (Name). An App that will help you stay organized!"
        guard let url = URL(string: "https://apps.apple.com/us/app/pixel-starships/id321756558") else { return }
        let objectsToShare = UIActivityViewController(activityItems: [textToShare, url], applicationActivities: nil)
        present(objectsToShare, animated: true)
    }
    
    private func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            // Show alert informing the user
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["bryandionizio@gmail.com"])
        composer.setSubject("(AppName) email support (iPhone)")
        composer.setMessageBody("I love your app but.... ", isHTML: false)
        
        present(composer, animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 4
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let section = indexPath.section, row = indexPath.row
        
        if (section == 1) {
            if row == 1 {
                if let url = URL(string: "https://www.instagram.com/bryan_iosdev/") {
                    UIApplication.shared.open(url)
                }
            }
            
            if row == 3 {
                if  let url = URL(string: "https://apps.apple.com/us/app/pixel-starships/id321756558") {
                    UIApplication.shared.open(url)
                }
            }
            
            if row == 2 {
                shareSheetTapped()
            }
            
        } else if (section == 2) {
            if row == 2 {
                showMailComposer()
            }
        }
    }
    //MARK: - Header and Footer layout functions.
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 100)
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let  footer = view as! UITableViewHeaderFooterView
        footer.tintColor =  UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 100)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 0
        } else {
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56 
    }
    
}

//MARK: - Section Heading

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            // Show error alert
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("Saved")
        case .sent:
            print("Email sent")
        case .failed:
            print("Failed to send")
        @unknown default:
            break
        }
        controller.dismiss(animated: true)
    }
}
