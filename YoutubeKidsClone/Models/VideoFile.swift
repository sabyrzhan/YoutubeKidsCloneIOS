//
//  VideoFile.swift
//  YoutubeKidsClone
//
//  Created by Sabyrzhan Tynybayev on 01.10.2022.
//

import Foundation
import UIKit
import AVFoundation
import os

struct VideoFile: Codable {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: VideoFile.self))
    
    var title: String?
    var videoNumber: Int?
    var url: URL?
    var fileName: String?
    
    func updatePreviewImage(imageView: UIImageView) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let filePath = dir?.appendingPathComponent(fileName!)
        let asset = AVURLAsset(url: filePath!)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        //let cgImage = try? await imgGenerator.image(at: CMTime(value: 10, timescale: 1))
        var operationQueue = OperationQueue()
        DispatchQueue.global(qos: .background).async {
            let operation1 = BlockOperation(block: {
                imgGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime(value: 30, timescale: 1))]) {
                    requestedTime, image, actualTime, result, err in
                    OperationQueue.main.addOperation({
                        if let image = image {
                            let uiImage = UIImage(cgImage: image)
                            imageView.image = uiImage
                            VideoFile.logger.info("Image found. Setting preview image")
                        } else {
                            if let err = err {
                                VideoFile.logger.error("Preview generation error: \(err.localizedDescription). File path: \(filePath!.absoluteString.removingPercentEncoding!)")
                            }
                        }
                    })
                }
            })
            operationQueue.addOperation(operation1)
            }
    }
    
    static func readFileNames() -> [VideoFile] {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let fileName = dir?.appendingPathComponent("file_list.json")
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        var result:[VideoFile] = []
        
        do {
            let data = try Data(contentsOf: fileName!)
            
            result = try jsonDecoder.decode([VideoFile].self, from: data)
        } catch {
            logger.warning("Error reading files: \(error.localizedDescription). Returning empty array")
        }
        
        for (i, elem) in result.enumerated() {
            result[i].fileName = elem.fileName!.uppercased()
        }
        
        return result
    }
}
