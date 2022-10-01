//
//  ViewPlayerViewController.swift
//  YoutubeKidsClone
//
//  Created by Sabyrzhan Tynybayev on 30.09.2022.
//

import UIKit
import AVFoundation
import AVKit

class ViewPlayerViewController: UIViewController, PlayerViewPreviewDelegate {
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    @IBOutlet weak var videoPlayerContainerView: UIView!
    
    var videoFiles: [VideoFile] = []
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let imageData = UIImage(named: "main_bg")?.jpegData(compressionQuality: 1.0)
//            {
//                save(imageData: imageData,
//                     toFolder: "MyAppImages",
//                     withFileName: "dog.jpeg")
//            }
        
        self.videoFiles = readFileNames()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //playVideo()
    }
    
    func playVideo(videoFile: VideoFile) {
        if let player = player {
            let playingURL = (player.currentItem?.asset as! AVURLAsset).url.absoluteString
            var index = playingURL.lastIndex(of: "/")
            index = playingURL.index(after: index!)
            let substr = playingURL[index!..<playingURL.endIndex]
            let playingPath = String(substr).removingPercentEncoding!
            let videoFilename = videoFile.fileName
            if playingPath == videoFilename {
                print("Already playing")
                videoPlayerContainerView.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                return
            }
            player.replaceCurrentItem(with: nil)
        }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let dir2 = dir?.appendingPathComponent(videoFile.fileName)
//        let image = UIImage(contentsOfFile: dir2!.absoluteString)
        
//        print(FileManager.default.fileExists(atPath: dir2!.absoluteString))
        let videoURL = URL(string: dir2!.absoluteString)
        player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoPlayerContainerView.bounds
        self.videoPlayerContainerView.layer.addSublayer(playerLayer)
        player?.play()

    }
    
    func readFileNames() -> [VideoFile] {
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
    
    func save(imageData: Data,
              toFolder folderName: String,
              withFileName fileName: String)
    {
        DispatchQueue.global().async
        {
            let manager = FileManager.default
            let documentFolder = manager.urls(for: .documentDirectory,
                                              in: .userDomainMask).last
            let folder = documentFolder?.appendingPathComponent(folderName)
            let file = folder?.appendingPathComponent(fileName)

            do {
                try manager.createDirectory(at: folder!,
                                            withIntermediateDirectories: true,
                                            attributes: [:])
                if let file = file
                {
                    try imageData.write(to: file)
                    print("file \(fileName) saved")
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
}

extension ViewPlayerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: "videoItem", for: indexPath) as! PlayerVideoPreviewCell
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let dir2 = dir?.appendingPathComponent("MyAppImages").appendingPathComponent("dog.jpeg")
        let data = try? Data(contentsOf: dir2!)
        let image = UIImage(data: data!)
        
        cell.videoFile = videoFiles[indexPath.row]
        cell.previewImage.image = image
        cell.delegate = self
        
    
        let filePath = dir?.appendingPathComponent(cell.videoFile!.fileName)
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
                            cell.previewImage.image = uiImage
                            print("Setting preview image")
                        } else {
                            print("Image is null")
                        }
                    })
                }
            })
            operationQueue.addOperation(operation1)
            }
        
        return cell
    }
    
    
}
