//
//  VideoFile.swift
//  YoutubeKidsClone
//
//  Created by Sabyrzhan Tynybayev on 01.10.2022.
//

import Foundation

struct VideoFile {
    var title: String?
    var videoNumber: Int?
    var url: URL?
    var fileName: String {
        get {
            let urlString = url!.absoluteString
            let number = String(format: "%05d", videoNumber!)
            return number + "_" + title! + ".MP4"
        }
    }
}
