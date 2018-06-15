//
//  GameCollectionViewController.swift
//  DoodbleBlueTask
//
//  Created by malli nallapati on 24/05/18.
//  Copyright © 2018 malliswarinallapati. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class GameCollectionViewController: UIViewController {
    
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var finishView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var chooseImageView: UIImageView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let xmlParserHelper = XMLParserHelper()
    var imagesList = [String]()
    var randomList = [String]()
    var imageStatus : Bool = false
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        if Rechability.isConnectedToInternet(viewController: self) == false{
//            let alert = UIAlertController(title: "Network error", message: "please check you internet connection", preferredStyle: .alert)
//
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
        downloadImageFile()

    }
    func initialSetUp(){
        collectionView.dataSource = self
        collectionView.delegate = self
        xmlParserHelper.delegate = self
        
        activityIndicator.frame = CGRect(x: UIScreen.main.bounds.size.width/2-20, y: UIScreen.main.bounds.size.height/2-20, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        finishView.alpha = 0
        bgView.alpha = 0
        noteView.alpha = 0
        //downloadImageFile()
    }
    
    func downloadImageFile(){
        
                if Rechability.isConnectedToInternet(viewController: self) == false{
                    let alert = UIAlertController(title: "Network error", message: "please check you internet connection", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
        
        guard let url = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne") else {return}
        removeExistingData()
       // activityIndicator.startAnimating()
        xmlParserHelper.parseXmlFromFile(path: url) { (success) in
            if success{
                self.activityIndicator.stopAnimating()
                self.collectionViewTopConstraint.constant = 5
                self.noteView.alpha = 0
                self.fetchDataFromServer()
            }
        }
    }
    func savingCoreData(imageUrl: String){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: "ImagesUrlEntity", in: context){
            let myItem = NSManagedObject(entity: entity, insertInto: context)
            myItem.setValue(imageUrl, forKey: "imageUrl")
            do {
                try context.save()
            }catch let nserror as NSError{
                print("ERROR: Coredata error \(nserror)")
            }
        }
    }
    func fetchDataFromServer()   {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImagesUrlEntity")
        do{
            imagesList.removeAll()
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject]{
                let imageUrl : String = data.value(forKey: "imageUrl") as! String
                if imagesList.count < 9 {
                    imagesList.append(imageUrl)
                }
            }
            self.randomList = imagesList
            self.collectionView.reloadData()
            self.noteView.alpha = 1
            let _ = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.flipImages), userInfo: nil, repeats: false)
        }catch{
            print("Error")
        }
    }

    @objc func flipImages() {
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        for indexPath in visibleCells {
            
            let cell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            
            UIView.transition(with: cell, duration: 1.0, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            }) { (true) in
                cell.imageView.alpha = 0.01
            }
        }
        UIView.animate(withDuration: 2.0, animations: {
            self.collectionViewTopConstraint.constant = 20
        }) { (status) in
            self.collectionViewTopConstraint.constant = 260
            self.bgView.alpha = 1
            self.bgView.layer.cornerRadius = 5
            self.bgView.layer.masksToBounds = true
            self.noteView.alpha = 0
            self.chooseImageView.sd_setImage(with: URL(string: self.getRandomImageUrl())) { (image, error, imageCacheType, url) in
            }
        }
    }
    @IBAction func gotItAction(_ sender: Any) {
        self.finishView.isHidden = true
        self.initialSetUp()
    }
    
    func getRandomImageUrl() -> String {
        if self.randomList.count > 0 {
            var imageUrlIndex: Int = 0
            imageUrlIndex = Int( arc4random() % UInt32(self.randomList.count) )
            let url = randomList[imageUrlIndex]
            randomList.remove(at: imageUrlIndex)
            return url
        } else {
            return ""
        }
    }
    
    func removeExistingData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImagesUrlEntity")
        do{
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject]{
                context.delete(data)
            }
        }catch{
            print("Error : in removingCoreData  ")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension GameCollectionViewController: ImagesResultDelegate{
    func parsedImagesUrl(image: String) {
        print("Image getting using delegate: \(image)")
        self.savingCoreData(imageUrl: image)
    }
}
extension GameCollectionViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)as! CollectionViewCell
        let imageUrl = imagesList[indexPath.row]
            cell.imageView.sd_setImage(with: URL(string: imageUrl) , placeholderImage: nil, options: SDWebImageOptions.continueInBackground) { (image, error, imageType, url) in
            }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        let cellImage = cell.imageView.image
        
        let randomImage = self.chooseImageView.image
        if randomImage != nil {
            
            if (cellImage?.isEqualToImage(image: randomImage!))! {
                
                UIView.transition(with: cell, duration: 1.0, options: UIViewAnimationOptions.transitionFlipFromRight, animations: {
                    
                }) { (status) in
                    cell.imageView.alpha = 1
                }
                let urlstr = getRandomImageUrl()
                
                self.chooseImageView.sd_setImage(with: URL(string: urlstr)) { (image, error, imageCacheType, url) in
                    if urlstr == "" {
                        UIView.animate(withDuration: 1.0, animations: {
                            self.finishView.alpha = 0.1
                        }, completion: { (status) in
                            self.finishView.alpha = 1.0
                            self.finishView.isHidden = false
                            
                        })
                    }
                }
            }
        }
    }
}

extension GameCollectionViewController: UICollectionViewDelegate{
    
}
extension GameCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width/3-10
        let cellHeight = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension UIImage {
    
    func isEqualToImage(image: UIImage) -> Bool {
        let data1: NSData = UIImagePNGRepresentation(self)! as NSData
        let data2: NSData = UIImagePNGRepresentation(image)! as NSData
        return data1.isEqual(data2)
    }
}
