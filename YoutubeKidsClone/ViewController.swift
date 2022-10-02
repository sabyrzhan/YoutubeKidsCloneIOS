//
//  ViewController.swift
//  YoutubeKidsClone
//
//  Created by Sabyrzhan Tynybayev on 30.09.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var videoFiles: [VideoFile] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoFiles = VideoFile.readFileNames()
        mainCollectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Preparing for \(segue.identifier)")
        if segue.identifier == "playVideoSegue" {
            print("Setting playVideoSegue values...")
            let dest = segue.destination as! ViewPlayerViewController
            let cell = sender as! MainCollectionCellCollectionViewCell
            
            dest.selectedVideoFile = cell.videoFile
        }
    }
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "videoPreviewPhoto", for: indexPath) as! MainCollectionCellCollectionViewCell
        
        let videoFile = videoFiles[indexPath.row]
        cell.videoFile = videoFile
        videoFile.updatePreviewImage(imageView: cell.previewImageView)
        
        return cell;
    }
    
}
