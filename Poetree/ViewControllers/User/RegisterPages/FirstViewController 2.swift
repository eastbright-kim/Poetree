//
//  FirstViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/21.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController, ViewModelBindable, StoryboardBased {
    
    
    var viewModel: UserRegisterViewModel!
    
    @IBOutlet weak var penNameTextField: UITextField!
    @IBOutlet weak var videoLayer: UIView!
    var avPlayerLooper: AVPlayerLooper!
    var avQueuePlayer: AVQueuePlayer!
    let asset = AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "ureru", ofType: "mp4")!))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideo()
    }
    
    
    func bindViewModel() {
        
    }
    
    
    func playVideo() {
        
        let item = AVPlayerItem(asset: asset)
        self.avQueuePlayer = AVQueuePlayer(playerItem: item)
        self.avPlayerLooper = AVPlayerLooper(player: self.avQueuePlayer, templateItem: item)
        
        let layer = AVPlayerLayer(player: self.avQueuePlayer)
        
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspectFill
        self.videoLayer.layer.addSublayer(layer)
        
        avQueuePlayer.play()
        
        self.videoLayer.bringSubviewToFront(self.penNameTextField)
    }
    
}
