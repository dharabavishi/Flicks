//
//  MovieViewController.swift
//  Flicks
//
//  Created by Ruchit Mehta on 10/13/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit
import MBProgressHUD
import ReachabilitySwift
class MovieViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var noInternetView: UIView!
    @IBOutlet weak var tblMovie: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var data:[NSDictionary]?
    
    let reachability = Reachability()!
    let refreshControlTable = UIRefreshControl()
    let refreshControlCollection = UIRefreshControl()
    
    var wsType:String = ""
   
    let btnToggle = UIButton()
    var arrMovie: [NSDictionary]!
    @IBOutlet weak var gridMovieViewCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.checkInternet()
        refreshControlTable.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        refreshControlCollection.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)

        
        tblMovie.insertSubview(refreshControlTable, at: 0)
        gridMovieViewCollection.insertSubview(refreshControlCollection, at: 0)
        
        setNavigationBar()
        
       
    
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.searchBar.endEditing(true)
        self.arrMovie = data
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                            name: ReachabilityChangedNotification,
                                                            object: reachability)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrMovie != nil
        {
            return arrMovie!.count
        }
        else
        {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionCell
        let dict = arrMovie![indexPath.row]
        if let img = dict["poster_path"] as? String
        {
            
            let path = "https://image.tmdb.org/t/p/w342\(img)"
            let fileURL = Foundation.URL(string:path)
            let imageRequest = URLRequest(url: fileURL!)
            
            cell.imgMovie.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.imgMovie.alpha = 0.0
                        cell.imgMovie.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.imgMovie.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.imgMovie.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
                    
            })
            
           
        }
        else
        {
            cell.imgMovie.image = nil;
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrMovie != nil
        {
            return arrMovie!.count
        }
        else
        {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        
        let dict = arrMovie![indexPath.row]
        let title = dict["title"] as! String
        let overview = dict["overview"] as! String
        
        cell.lblTitle.text = title
        cell.lblOverview.text = overview
        
        if let img = dict["poster_path"] as? String
        {
            
            let path = "https://image.tmdb.org/t/p/w342\(img)"
            print(path)
            let fileURL = Foundation.URL(string:path)
            cell.imgPosterImage.setImageWith(fileURL!)
            let imageRequest = URLRequest(url: fileURL!)
            
            cell.imgPosterImage.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.imgPosterImage.alpha = 0.0
                        cell.imgPosterImage.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.imgPosterImage.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.imgPosterImage.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
                    
            })

        }
        else
        {
            cell.imgPosterImage.image = nil;
        }
        
        
        //cell.selectionStyle = .none
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func checkInternet()
    {
        reachability.whenReachable = { reachability in
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.noInternetView.isHidden = true
                self.getMovie()
            }
            
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.noInternetView.isHidden = false
            }
            
        }

    }
    func getMovie()
    {

        
        MBProgressHUD.showAdded(to: self.view, animated: true)
    
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(wsType)?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    self.data = responseDictionary["results"] as? [NSDictionary]
                    self.arrMovie = responseDictionary["results"] as? [NSDictionary]
                    
                    
                   
                    
                }
                else
                {
                    
                }
                if(!self.isList())
                {
                    self.refreshControlCollection.endRefreshing()
                    self.gridMovieViewCollection.reloadData()
                }
                else
                {
                    self.refreshControlTable.endRefreshing()
                    self.tblMovie.reloadData()
                }
                
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        getMovie()
    }
    @IBAction func onListGridToggle(_ sender: UIButton) {
        
        if isList()
        {
            tblMovie.isHidden = true
            gridMovieViewCollection.isHidden = false
            gridMovieViewCollection.reloadData()
            //btnToggle.setTitleTextAttributes("||", for: UIControlState.normal)
            //btnToggle.setBackgroundImage(nil, for: UIControlState.normal, barMetrics: UIBarMetrics.default)
            //btnToggle.setBackgroundImage(UIImage(named:"list"), for: UIControlState.normal, barMetrics: UIBarMetrics.default)
            btnToggle.setImage(UIImage(named:"list"), for: .normal)
            
           
        }
        else
        {
            tblMovie.isHidden = false
            gridMovieViewCollection.isHidden = true
            tblMovie.reloadData()
             //btnToggle.setBackgroundImage(nil, for: UIControlState.normal, barMetrics: UIBarMetrics.default)
            //btnToggle.setBackgroundImage(UIImage(named:"grid"), for: UIControlState.normal, barMetrics: UIBarMetrics.default)
            btnToggle.setImage(UIImage(named:"grid"), for: .normal)
        }
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        arrMovie = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in
//            return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
//        })
//        
//    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            arrMovie = data
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            arrMovie = arrMovie.filter({(dataItem: NSDictionary) -> Bool in
                let str = dataItem["title"] as? String
                // If dataItem matches the searchText, return true to include it
                if str?.range(of: searchText) != nil {
                    return true
                } else {
                    return false
                }
                
                
            })
        }
        if(isList())
        {
            tblMovie.reloadData()
        }
        else
        {
            gridMovieViewCollection.reloadData()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailViewController = segue.destination as! DetailViewController
        if(isList())
        {
            let indexpath = self.tblMovie.indexPath(for: sender as! MovieCell)
            detailViewController.dictDetail = arrMovie![indexpath!.row]
            
            

        }
        else
        {
            let indexpath = self.gridMovieViewCollection.indexPath(for: sender as! MovieCollectionCell)
            detailViewController.dictDetail = arrMovie![indexpath!.row]
        }
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
        }
    }
    func setNavigationBar(){
        
        if(wsType=="top_rated")
        {
            self.title = "Top Rated"
        }
        else
        {
            self.title = "Now Playing"
        }
        btnToggle.setImage(UIImage(named: "grid"), for: .normal)
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 30, height: 30))
        
        btnToggle.frame = rect
        
        btnToggle.addTarget(self, action: #selector(onListGridToggle), for: .touchUpInside)
        
        //.... Set Right/Left Bar Button item
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnToggle
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationController?.navigationBar.barTintColor =  UIColor.init(red: CGFloat(228)/255, green: CGFloat(171)/255, blue: CGFloat(83)/255, alpha: 1)
 
    }
    
    func isList()->Bool
    {
        if tblMovie.isHidden
        {
            return false
        }
        else
        {
            return true
        }
    }

    
    @IBAction func onTap(_ sender: AnyObject) {
        
        self.searchBar.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchBar.endEditing(true)
        self.arrMovie = data
        self.view.endEditing(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchBar.endEditing(true)
        self.arrMovie = data
        self.view.endEditing(true)
    }
    

}
