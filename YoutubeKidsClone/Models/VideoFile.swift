//
//  VideoFile.swift
//  YoutubeKidsClone
//
//  Created by Sabyrzhan Tynybayev on 01.10.2022.
//

import Foundation
import UIKit
import AVFoundation

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
    
    func updatePreviewImage(imageView: UIImageView) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let filePath = dir?.appendingPathComponent(fileName)
        let asset = AVURLAsset(url: filePath!)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        //let cgImage = try? await imgGenerator.image(at: CMTime(value: 10, timescale: 1))
        var operationQueue = OperationQueue()
        DispatchQueue.global(qos: .background).async {
            let operation1 = BlockOperation(block: {
                
                imgGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime(value: 10, timescale: 1))]) {
                    requestedTime, image, actualTime, result, err in
                    OperationQueue.main.addOperation({
                        if let image = image {
                            let uiImage = UIImage(cgImage: image)
                            imageView.image = uiImage
                            print("Setting preview image")
                        } else {
                            print("Image is null")
                        }
                    })
                }
            })
            operationQueue.addOperation(operation1)
            }
    }
    
    static func readFileNames() -> [VideoFile] {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let fileName = dir?.appendingPathComponent("videos_url.txt")
        
        let data = try! String(contentsOf: fileName!, encoding: .utf8)
        let lines = data.components(separatedBy: .newlines)
        
        var result:[VideoFile] = []
        
        var title: String = ""
        
        var videoNumber = 1
        
        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            if line.starts(with: "#") {
                let index = line.index(after: line.firstIndex(of: "#")!)
                let range = index..<line.endIndex
                title = String(line[range])
            } else {
                let videoFile = VideoFile(title: title, videoNumber: videoNumber, url: URL(string: line))
                result.append(videoFile)
                videoNumber += 1
            }
        }
        
        return result
    }
}
