//
//  RecordCell.swift
//  Timeless
//
//  Created by Ivan Tkachenko on 10/2/18.
//  Copyright © 2018 Ivan Tkachenko. All rights reserved.
//

import UIKit
import ReactiveKit

class RecordCell: UITableViewCell {

    static let identifier = String(describing: RecordCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var onReuseBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuseBag.dispose()
    }
    
}
