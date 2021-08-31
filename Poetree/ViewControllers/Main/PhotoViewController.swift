//
//  PhotoViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/26.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import NSObject_Rx

class PhotoViewController: UIViewController, HasDisposeBag, StoryboardBased {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var firstNoticeLabel: UILabel!
    @IBOutlet weak var secondNoticeLabel: UILabel!
    
    var poemService: PoemService!
    var photoService: PhotoService!
    var selectedIndexPath: IndexPath!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDelegate()
        bindCollectionView()
        noticeLabelAni()
    }
    
    
    func noticeLabelAni(){
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
            self.firstNoticeLabel.alpha = 1
        } completion: { firstNoticeFadeIn in
            
            if firstNoticeFadeIn {
                UIView.animate(withDuration: 1.5, delay: 1, options: .curveEaseIn) {
                    self.firstNoticeLabel.alpha = 0
                } completion: { firstNoticeFadeout in
                    
                    if firstNoticeFadeout {
                        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
                            self.secondNoticeLabel.alpha = 1
                            
                        } completion: { SecondNoticefadein in
                            if SecondNoticefadein {
                                UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
                                    self.secondNoticeLabel.alpha = 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func collectionViewDelegate() {
        
        photoCollectionView.decelerationRate = .fast
        photoCollectionView.isPagingEnabled = false
        photoCollectionView.delegate = self
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: photoCollectionView.frame.size.height)
        flowlayout.minimumInteritemSpacing = 20
        flowlayout.minimumLineSpacing = 20
        flowlayout.scrollDirection = .horizontal
        photoCollectionView.collectionViewLayout = flowlayout
    }
    
    func bindCollectionView() {
        
        let photos = photoService.photos().map(photoService.getThisWeekPhoto)
        
        
        photos
            .bind(to: photoCollectionView.rx.items(cellIdentifier: "PhotoViewCell", cellType: PhotoViewCollectionViewCell.self)){ index, photo, cell in
                cell.imageView.kf.setImage(with: photo.url)
            }
            .disposed(by: rx.disposeBag)
        
        
        photoCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
        
        
        photoCollectionView.rx.modelSelected(WeekPhoto.self)
            .subscribe(onNext:{[unowned self] weekPhoto in
                
                let viewModel = WriteViewModel(poemService: self.poemService, weekPhoto: weekPhoto, editingPoem: nil)
                
                var vc = WritingViewController.instantiate(storyboardID: "WritingRelated")
                vc.bind(viewModel: viewModel)
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            })
            .disposed(by: rx.disposeBag)
        
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard let layout = self.photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            
            let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
            
            let estimatedIndex = scrollView.contentOffset.x / cellWidthIncludingSpacing
            let index: Int
            if velocity.x > 0 {
                index = Int(ceil(estimatedIndex))
            } else if velocity.x < 0 {
                index = Int(floor(estimatedIndex))
            } else {
                index = Int(round(estimatedIndex))
            }
            
            targetContentOffset.pointee = CGPoint(x: CGFloat(index) * cellWidthIncludingSpacing, y: 0)
        }
}
