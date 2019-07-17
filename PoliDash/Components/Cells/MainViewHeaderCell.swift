//
//  MainViewHeaderCell.swift
//  PoliDash
//
//  Created by Ігор on 2/22/19.
//  Copyright © 2019 Sergey Nazarov. All rights reserved.
//

import UIKit

class SearchBar: UISearchBar {
    var searchButton: UIButton?
}

class MainViewHeaderCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var searchBar: SearchBar?
    @IBOutlet weak var searchButton: UIButton?
    weak var delegate: MainViewController?

    @IBAction func searchAction() {
        self.searchButton!.isHidden = true
        self.searchBar?.searchButton = self.searchButton
        self.searchBar?.delegate = self.delegate
        self.searchBar?.isHidden = false
        self.searchBar?.becomeFirstResponder()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
