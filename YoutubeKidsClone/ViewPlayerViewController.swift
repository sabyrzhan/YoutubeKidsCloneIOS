//
//  ViewPlayerViewController.swift
//  YoutubeKidsClone
//
//  Created by Sabyrzhan Tynybayev on 30.09.2022.
//

import UIKit
import AVFoundation
import AVKit

class ViewPlayerViewController: UIViewController {
    @IBOutlet weak var videoListCollectionView: UICollectionView!
    @IBOutlet weak var videoPlayerContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageData = UIImage(named: "main_bg")?.jpegData(compressionQuality: 1.0)
            {
                save(imageData: imageData,
                     toFolder: "MyAppImages",
                     withFileName: "dog.jpeg")
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    
    func playVideo() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let dir2 = dir?.appendingPathComponent("video.MP4")
//        let image = UIImage(contentsOfFile: dir2!.absoluteString)
        
//        print(FileManager.default.fileExists(atPath: dir2!.absoluteString))
        print("VIdeoURL: \(dir2!.absoluteString)")
        let videoURL = URL(string: dir2!.absoluteString)
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoPlayerContainerView.bounds
        self.videoPlayerContainerView.layer.addSublayer(playerLayer)
        player.play()

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
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoListCollectionView.dequeueReusableCell(withReuseIdentifier: "videoItem", for: indexPath) as! PlayerVideoPreviewCell
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let dir2 = dir?.appendingPathComponent("MyAppImages").appendingPathComponent("dog.jpeg")
        let data = try? Data(contentsOf: dir2!)
        let image = UIImage(data: data!)
        
        cell.previewImage.image = image
        print("IMage shown")
        return cell
    }
    
    
}
