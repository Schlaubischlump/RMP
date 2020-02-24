//
//  DetailViewController.swift
//  RMP
//
//  Created by David Klopp on 02.01.20.
//  Copyright © 2020 David Klopp. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    var selectedRows: [IndexPath] = []

    func configureView() {
        if let tableView = tableView, let _ = basicNeed {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.allowsMultipleSelection = true
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.view.backgroundColor = .white

        self.configureView()

        #if targetEnvironment(macCatalyst)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        #endif
    }

    var basicNeed: BasicNeed? {
        didSet {
            self.configureView()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let need = basicNeed else { return 0 }
        return need.questionKeys(strongDesire: (section != 1)).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .none

        #if targetEnvironment(macCatalyst)
        cell.textLabel?.font = .systemFont(ofSize: 16.0)
        cell.backgroundColor = .clear
        #endif

        let questions = basicNeed!.questionKeys(strongDesire: (indexPath.section != 1))
        cell.textLabel!.text = "\(indexPath.section*3 + indexPath.row+1). " + questions[indexPath.row].localized()

        cell.selectionStyle = .none
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = .byWordWrapping
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString((section == 0) ? "STRONG" : "WEAK", comment: "").capitalized
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedRows.contains(indexPath) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            #if targetEnvironment(macCatalyst)
            cell.accessoryType = (cell.accessoryType == .checkmark) ? .none : .checkmark
            #else
            cell.accessoryType = .checkmark
            #endif
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            #if targetEnvironment(macCatalyst)
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                if let index = selectedRows.firstIndex(of: indexPath) {
                    selectedRows.remove(at: index)
                }
            } else {
                cell.accessoryType = .checkmark
                selectedRows.append(indexPath)
            }
            #else
            cell.accessoryType = .checkmark
            selectedRows.append(indexPath)
            #endif
        }
    }

    #if !targetEnvironment(macCatalyst)
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }

        if let index = selectedRows.firstIndex(of: indexPath) {
            selectedRows.remove(at: index)
        }
    }
    #endif
}

