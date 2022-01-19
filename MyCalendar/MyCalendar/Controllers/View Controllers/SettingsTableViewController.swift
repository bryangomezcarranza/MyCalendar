//
//  SettingsTableViewController.swift
//  MyCalendar
//
//  Created by Bryan Gomez on 9/13/21.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var bottomView: UIView!
    
    let defautls = UserDefaults.standard
    let darkModeToggled = "darkModeToggled"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarAppearance()
        tableView.backgroundColor = UIColor(named: "tableview-section")
        
        startObserving(&UserInterfaceStyleManager.shared)
        darkModeSwitch.isOn = UserInterfaceStyleManager.shared.currentStyle == .dark
        
    }
    
    //MARK: - Actions
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        
        let darkModeOn = sender.isOn
        UserDefaults.standard.set(darkModeOn, forKey: UserInterfaceStyleManager.userInterfaceStyleDarkModeOn)
        UserInterfaceStyleManager.shared.updateUserInterfaceStyle(darkModeOn)
    }
    
    
    //MARK: - UI
    private func navBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navbar-tabbar")
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    //MARK: - Private Functions
    
    private func shareSheetTapped() {
        let textToShare = "Keep track of your events and tasks with Eventz. An App that will help you stay organized!"
        guard let url = URL(string: "https://apps.apple.com/us/app/eventz-events-reminders/id1589629318") else { return }
        let objectsToShare = UIActivityViewController(activityItems: [textToShare, url], applicationActivities: nil)
        present(objectsToShare, animated: true)
    }
    
    private func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["eventzapplication@gmail.com"])
        composer.setSubject("Eventz email support (iPhone)")
        composer.setMessageBody("I love your app but.... ", isHTML: false)
        
        present(composer, animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section, row = indexPath.row
        
        if (section == 0) {
            if row == 0 {
                if let url = URL(string: "https://twitter.com/app_eventz") {
                    UIApplication.shared.open(url)
                }
            }
            
            if row == 1 {
                if let url = URL(string: "https://www.instagram.com/eventzapplication/") {
                    UIApplication.shared.open(url)
                }
            }
            
            if row == 3 {
                if  let url = URL(string: "https://apps.apple.com/us/app/eventz-events-reminders/id1589629318") {
                    UIApplication.shared.open(url)
                }
            }
            
            if row == 2 {
                shareSheetTapped()
            }
            
        } else if (section == 1) {
            if row == 1 {
                showMailComposer()
            }
        }
    }
    //MARK: - Header and Footer layout functions.
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = UIColor(named: "tableview-section")
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let  footer = view as! UITableViewHeaderFooterView
        footer.tintColor =  UIColor(named: "tableview-section")
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else {
            return 50
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

