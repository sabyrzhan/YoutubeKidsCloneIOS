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
    var playerLayer: AVPlayerLayer?
    
    
    var selectedVideoFile: VideoFile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let imageData = UIImage(named: "main_bg")?.jpegData(compressionQuality: 1.0)
//            {
//                save(imageData: imageData,
//                     toFolder: "MyAppImages",
//                     withFileName: "dog.jpeg")
//            }
        
        self.videoFiles = VideoFile.readFileNames()
        videoListCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.replaceCurrentItem(with: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var i = 0
        for videoFile in videoFiles {
            if videoFile.fileName == selectedVideoFile?.fileName {
                let indexPath = IndexPath(row: i, section: 0)
                videoListCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                playVideo(videoFile: selectedVideoFile!)
                break
            }
            
            i += 1
        }
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
                //videoPlayerContainerView.frame = UIScreen.main.bounds
//                if let playerLayer = playerLayer {
//                    print("Player layer is active")
////                    UIView.animate(withDuration: 0.15) {
////                            playerLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI / 2)))
////                            playerLayer.frame = UIScreen.main.bounds
////                        }
//                    videoPlayerContainerView.frame = UIScreen.main.bounds
//                    playerLayer.frame = UIScreen.main.bounds
//                    self.view.bringSubviewToFront(videoPlayerContainerView)
////                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////                        self.view.setNeedsDisplay()
////                        self.videoPlayerContainerView.setNeedsDisplay()
////                        playerLayer.setNeedsDisplay()
////                    }
//
//                }
                
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
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.videoPlayerContainerView.bounds
        playerLayer!.videoGravity = .resizeAspect
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        videoPlayerContainerView.addGestureRecognizer(tapGestureRecognizer)
        
        self.videoPlayerContainerView.layer.addSublayer(playerLayer!)
        player?.play()

    }
    
    var previousFrameView: CGRect?
    var previousFramePlayer: CGRect?
    var isNavBarHidden: Bool = false
    
    @objc func onTap() {
        if let playerLayer = playerLayer {
            let currentViewFrame = videoPlayerContainerView.frame
            let currentPlayerFrame = playerLayer.frame
            
            if let previousFrameView = previousFrameView,
               let previousFramePlayer = previousFramePlayer {
                videoPlayerContainerView.frame = previousFrameView
                playerLayer.frame = previousFramePlayer
            } else {
                videoPlayerContainerView.frame = UIScreen.main.bounds
                playerLayer.frame = UIScreen.main.bounds
                self.view.bringSubviewToFront(videoPlayerContainerView)
            }
            
            self.navigationItem.setHidesBackButton(!isNavBarHidden, animated: true)
            isNavBarHidden = !isNavBarHidden
            
            previousFrameView = currentViewFrame
            previousFramePlayer = currentPlayerFrame
        }
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
