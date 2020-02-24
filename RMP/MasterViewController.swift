//
//  MasterViewController.swift
//  RMP
//
//  Created by David Klopp on 02.01.20.
//  Copyright © 2020 David Klopp. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil

    var selectedQuestions: [BasicNeed:[IndexPath]] = [
        .ACCEPTANCE: [],
        .CURIOSITY: [],
        .EATING: [],
        .FAMILY: [],
        .HONOR: [],
        .IDEALISM: [],
        .INDEPENDENCE: [],
        .ORDER: [],
        .PHYSICAL_ACTIVITY: [],
        .POWER: [],
        .ROMANCE: [],
        .SAVING: [],
        .SOCIAL_CONTACT: [],
        .STATUS: [],
        .TRANQUILITY: [],
        .VENGEANCE: []
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers.last as! UINavigationController).topViewController as? DetailViewController
            //detailViewController?.basicNeed = BasicNeed.asArray[0]
        }

        #if targetEnvironment(macCatalyst)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        #else
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = NSLocalizedString("BASIC_NEEDS", comment: "")
        // Add the buttons for iOS devices
        let saveButton = UIBarButtonItem(title: NSLocalizedString("RESULT", comment: ""), style: .plain, target: self, action: #selector(finishTest))
        let resetButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetTest))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = resetButton
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // If only one viewController is visible we do not want to call this.
        if self.splitViewController?.displayMode == .allVisible && !self.splitViewController!.isCollapsed {
            self.perform(#selector(resetTest), with: nil, afterDelay: 0)
        }
    }

    // MARK: - Buttons

    @objc func resetTest(sender: Any?) {
        self.tableView.becomeFirstResponder()
        self.detailViewController?.selectedRows = []

        for (key, _) in selectedQuestions {
           selectedQuestions[key] = []
        }

        // If both views are visible prepare the detailViewController.
        if self.splitViewController?.displayMode == .allVisible && !self.splitViewController!.isCollapsed {
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)

            let segue = UIStoryboardSegue(identifier: "showDetail", source: self, destination: detailViewController!.navigationController!)
            self.prepare(for: segue, sender: nil)
        }
    }

    @objc func finishTest(sender: Any?) {
        // Update currently active view values
        if let detail = detailViewController, let need = detail.basicNeed {
            selectedQuestions[need] = detail.selectedRows
        }

        var scores: [BasicNeed : Int] = [:]
        for (key, value) in selectedQuestions {
            let strongSum = value.filter({$0.section == 0}).count
            let weakSum = value.filter({$0.section == 1}).count
            scores[key] = strongSum-weakSum
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "resultViewController") as! ResultViewController
        vc.chartData = scores

        let navController = UINavigationController(rootViewController: vc)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissResult))
        vc.navigationItem.rightBarButtonItem = doneButton

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveResult))
        vc.navigationItem.leftBarButtonItem = saveButton

        vc.navigationController?.navigationBar.prefersLargeTitles = true

        self.present(navController, animated: true, completion: nil)
    }

    @objc func dismissResult(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func saveResult(sender: Any?) {
        guard let navController = self.presentedViewController as? UINavigationController,
            let vc = navController.topViewController as? ResultViewController else { return }

        let fileManager = FileManager.default
        let docURL = fileManager.temporaryDirectory.appendingPathComponent("result.png")
        try! vc.chartView.asImage().pngData()?.write(to: docURL)
        let documentPicker = UIDocumentPickerViewController(url: docURL, in: .exportToService)
        documentPicker.delegate = self
        navController.present(documentPicker, animated: true)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detail = detailViewController, let need = detail.basicNeed {
                selectedQuestions[need] = detail.selectedRows
            }

            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.basicNeed =  BasicNeed.asArray[indexPath.row]
                controller.selectedRows = selectedQuestions[controller.basicNeed!]!
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BasicNeed.asArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        #if targetEnvironment(macCatalyst)
        cell.textLabel?.font = .systemFont(ofSize: 16.0)
        cell.backgroundColor = .clear
        #endif
        cell.textLabel!.text = BasicNeed.asArray[indexPath.row].rawValue.localized()
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}


extension MasterViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let destUrl = urls[0]
        let fileManager = FileManager.default
        let docURL = fileManager.temporaryDirectory.appendingPathComponent("result.png")

        if fileManager.fileExists(atPath: destUrl.path) {
             try! fileManager.removeItem(atPath: destUrl.path)
        }
        try! fileManager.moveItem(at: docURL, to: destUrl)
    }
}

