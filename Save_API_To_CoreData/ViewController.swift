//
//  ViewController.swift
//  Save_API_To_CoreData
//
//  Created by Deepali on 19/04/24.
//

import UIKit
import Kingfisher
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var PhotoCollectionView: UICollectionView!
    var url : URL?
    var urlRequest : URLRequest?
    var urlSession : URLSession?
    var photos :[Album] = []
    var uiNib : UINib?
    var photoCollectionViewCell : PhotoCollectionViewCell?
    private var cellIdentifier = "PhotoCollectionViewCell"
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotoCollectionView.dataSource = self
        fetchDataUsingDecoder()
        registerXIBWithCollectionView()
        saveDataToCoreData()
       // fetchFromCoreData()
        
    }
    
    func registerXIBWithCollectionView(){
        
        let uiNib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        self.PhotoCollectionView.register(uiNib, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
    }

    func fetchDataUsingDecoder(){
        url = URL(string: "https://jsonplaceholder.typicode.com/photos")
        urlRequest = URLRequest(url: url!)
        urlRequest?.httpMethod = "GET"
        urlSession = URLSession(configuration: .default)
        
        let dataTask = urlSession?.dataTask(with: urlRequest!) {
            data, response, error
            in
            let data = try! JSONDecoder().decode([Album].self, from: data!)
            print(data)
        }
        
        dataTask?.resume()
    }
    
    func saveDataToCoreData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedcontext = appDelegate.persistentContainer.viewContext
        
        for photo in photos{
            
            let photoEntity = Photo(context: managedcontext)
            photoEntity.albumId = Int32(photo.albumId)
            photoEntity.id = Int32(photo.id)
            photoEntity.title = photo.title
            photoEntity.url = photo.url
            photoEntity.thumbnailUrl = photo.thumbnailUrl
            
            do{
                try managedcontext.save()}
            catch{
                print("Error occured while saving data in core data\(error)")
            }
            
            DispatchQueue.main.async {
                self.PhotoCollectionView.reloadData()
            }
                
        }
        
        func fetchFromCoreData(){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedcontext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Photo")

            do
            {
                let fetchResult = try managedcontext.fetch(fetchRequest) as! [NSManagedObject]
                for eachFetchResult in fetchResult{
                    print(eachFetchResult.value(forKey: "albumId") as! Int)
                    print(eachFetchResult.value(forKey: "id") as! Int)
                    print(eachFetchResult.value(forKey: "title") as! String)
                    print(eachFetchResult.value(forKey: "url") as! String)
                }
                self.PhotoCollectionView.reloadData()
                }

            catch{

                print("Error fetching photos from Core Data: \(error)")
            }

        }
    
    }
    
}

extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        photoCollectionViewCell = (self.PhotoCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell)
        photoCollectionViewCell?.albumIdLabel.text = String(photos[indexPath.item].albumId)
        photoCollectionViewCell?.idLabel.text = String(photos[indexPath.item].id)
        photoCollectionViewCell?.titleLabel.text = photos[indexPath.item].title
        photoCollectionViewCell?.imageLabel.kf.setImage(with: URL(string: photos[indexPath.row].url))
        return photoCollectionViewCell!
    }
    
}
