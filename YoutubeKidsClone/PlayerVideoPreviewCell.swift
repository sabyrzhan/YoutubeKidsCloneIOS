//
//  PlayerVideoPreviewCell.swift
//  YoutubeKidsClone
//
//  Created by Sabyrzhan Tynybayev on 01.10.2022.
//

import UIKit

protocol PlayerViewPreviewDelegate {
    func playVideo(videoFile: VideoFile)
}

class PlayerVideoPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImage: UIImageView!
    var videoFile: VideoFile?
    
    var delegate: PlayerViewPreviewDelegate?
    
    
    @IBAction func previewButtonTapped(_ sender: UIButton) {
        delegate?.playVideo(videoFile: videoFile!)
    }
    
}
