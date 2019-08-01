//
//  ViewController.swift
//  myFourthNSURLProject
//
//  Created by rails on 22/07/19.
//  Copyright © 2019 rails. All rights reserved.
//

import UIKit

class SongHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    //  MARK: - class properties
    @IBOutlet weak var songSearchBar: UISearchBar!
    @IBOutlet weak var songTableView: UITableView!
    var imageDictionary = Dictionary<Int,UIImage>()
    var songDataList = Array<Dictionary<String,Any>>()
    var songDataList2 = Array<SongModelStructure>()
    var filtered = Array<Dictionary<String,Any>>()
    var filtered2 = Array<SongModelStructure>()
    var flag = true
    var searchActive : Bool = false
    var myIndex = Int()
    var songSearch = "latest"
    var stringPath = String()
    var urlPath : URL?
    var documentUrl : URL?
    var imageUrl : URL?
    var imageUrlDictionary = Dictionary<Int,URL>()
    
   
    

    //    MARK: - view methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        func calcDecrement(forDecrement total: Int) -> () -> Int {
            var overallDecrement = 100
            func decrementer() -> Int {
                overallDecrement -= total
                print(overallDecrement)
                return overallDecrement
            }
            return decrementer
        }
        
        let decrem = calcDecrement(forDecrement: 18)
        decrem()
        decrem()
        decrem()
        
        
        
        
        fetchAPIData(songSearch: songSearch)
        songSearchBar.delegate = self
        ImageFolderExist()
    }
    
    //    MARK: - api methods
    func fetchAPIData(songSearch: String) {
        print("start parse")
        print("hitting url")
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.query = "media=music&entity=song&term=\(songSearch)"
        
        guard let url2 = urlComponents.url else { return }
        URLSession.shared.dataTask(with: url2) { (data,response,error) in
            print("we are in session")
            do{
                if let data = data{
                    let decoder = JSONDecoder()
                    print(data)
                    let jsonMainResponse = try decoder.decode(ApiResponseModelStructure.self, from: data)
                    if let resultList = jsonMainResponse.results{
                        self.songDataList2 = resultList
                    }
                }
                print("complete loading data")
                self.setDataToUI()
                }
            catch let error1  {
                print("api call error")
                print(error1)
            }
            
            }.resume()
        
    }
    
    func fetchImageFromApi(trackId: Int, url: String){
        let urlString = url
        let imageURL = URL(string: urlString)
        URLSession.shared.dataTask(with: imageURL!) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.imageDictionary[trackId] = image
                print("we are checking on scroll image download \(self.imageDictionary.count)")
                self.songTableView.reloadData()
            }
            }.resume()
    }
    
    func setDataToUI(){
        DispatchQueue.main.async { [weak self] in
            print("we are in setData")
            self?.songTableView.reloadData()
        }
    }
    
    
    
    //    MARK: - segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? SongDetailViewController else{
            return
        }
        
        if(searchActive){
            nextVC.songDataStructure = filtered2[myIndex]
        }
        else{
            nextVC.songDataStructure = songDataList2[myIndex]
        }
    }

    
    
    //    MARK: - file operations
    func getImageFromLocalStorage(trackId: Int) -> Bool{
        if let imageUrl = imageUrl {
            
            let trackPath = imageUrl.appendingPathComponent(String(trackId))
            let imagePath = trackPath.appendingPathComponent("image" + String(trackId) + ".png")
            
            do {
                print("retrieving image from local")
                let imageFileUrl = URL(fileURLWithPath: imagePath.absoluteString)
                let imageData = try Data.init(contentsOf: imageFileUrl)
                let retrivedImg = UIImage.init(data: imageData)!
                self.imageDictionary[trackId] = retrivedImg
                return true
            }
            catch {
                print("error in creating directory")
                print(error.localizedDescription);
            }
        }
        return false
    }
    
    func saveDataToDocuments(trackId: Int){
        var flag = false
        if let imageUrl = imageUrl {
            
            let trackPath = imageUrl.appendingPathComponent(String(trackId))
            if !FileManager.default.fileExists(atPath: trackPath.absoluteString) {
                do {
                    try FileManager.default.createDirectory(atPath: trackPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
                    flag = true
                } catch {
                    print("error in creating directory")
                    print(error.localizedDescription);
                }
            }
            else{
                print("folder with same name exist")
            }
            
            if(flag){

                if let imageObj = imageDictionary[trackId]{
                    if let imageData = imageObj.pngData() {
                        let localImageURL = trackPath.appendingPathComponent("image" + String(trackId)).appendingPathExtension("png")
                        do {
                            let fileUrl = URL(fileURLWithPath: localImageURL.absoluteString)
                            try imageData.write(to: fileUrl)

                            self.imageUrlDictionary[trackId] = localImageURL
                            print("image saved successfully")
                        }
                        catch let err {
                            print("file cannot saved")
                            print(err.localizedDescription)
                        }
                    }
                }
                else{
                    print("image url is emptlyh")
                }
            }
           
        }
    }
    
    func ImageFolderExist(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print("path")
        print(type(of: paths[0]))
        let documentStringPath = paths[0]
        documentUrl = URL(string: documentStringPath)!
        if let documentUrl = documentUrl {
            imageUrl = documentUrl.appendingPathComponent("Images")
            if let imageUrl = imageUrl {
                if !FileManager.default.fileExists(atPath: imageUrl.absoluteString) {
                    do {
                        try FileManager.default.createDirectory(atPath: imageUrl.absoluteString, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("error in creating directory")
                        print(error.localizedDescription);
                    }
                }
                else{
                    print("folder with same name exist")
                }
            }
        }
    }
    
    //    MARK: - searchBar methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("we are filtering")
        filtered2 = songDataList2.filter({ (songStructure) -> Bool in

            print("we are in filter function")
            if let trackName = songStructure.trackName{
                if (trackName.localizedCaseInsensitiveContains(searchText)){
                    return true
                }
            }
            return false
        })
        print("we finished filtering")
        if(searchText.isEmpty){
            searchActive = false;
            print("search active false")
        } else {
            searchActive = true;
            print("search active true")
        }
        self.songTableView.reloadData()
    }
    
    //    MARK: - tableView methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        performSegue(withIdentifier: "segueToSongDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            print("count of table \(filtered.count)")
            return filtered2.count
        }
        return songDataList2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var url = "nil"
        var trackId : Int?
        if(searchActive){
            if let imageUrl = filtered2[indexPath.row].image30 {
                url = imageUrl
            }
            if let NSTrack = filtered2[indexPath.row].trackId {
                trackId = NSTrack
            }
        }
        else{
            if let imageUrl = songDataList2[indexPath.row].image30 {
                url = imageUrl
            }
            if let NSTrack = songDataList2[indexPath.row].trackId {
                trackId = NSTrack
            }
        }
        
        if let trackId = trackId{
            
            if imageDictionary[trackId] == nil{
                if(!getImageFromLocalStorage(trackId: trackId)){
                    print("you got false")
                    if url != "nil"{
                        fetchImageFromApi(trackId: trackId, url: url)
                    }
                }
            }
        }
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songCellReuseIdentifier", for: indexPath) as? songTableViewCell else{
            return songTableViewCell()
        }
        
        if(!searchActive){
            cell.songNameLabel.text = songDataList2[indexPath.row].trackName
            cell.artistNameLabel.text = songDataList2[indexPath.row].artistName
            if let price = songDataList2[indexPath.row].price{
                cell.songPriceLabel.text = "$ " + String(price)
            }
        }
        else{
            cell.songNameLabel.text = filtered2[indexPath.row].trackName
            cell.artistNameLabel.text = filtered2[indexPath.row].artistName
            if let price = filtered2[indexPath.row].price{
                cell.songPriceLabel.text = "$ " + String(price)
            }
        }
        
        if let trackId = trackId {
            if(imageDictionary[trackId] != nil){
                cell.songImageView.image = imageDictionary[trackId]
                saveDataToDocuments(trackId: trackId)
            }
        }
        songTableView.rowHeight = 50
        print("setting data to cell")
        return cell
    }
}
