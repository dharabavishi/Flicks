//
//  DetailViewController.swift
//  Flicks
//
//  Created by Ruchit Mehta on 10/14/16.
//  Copyright © 2016 Dhara Bavishi. All rights reserved.
//

import UIKit
import AFNetworking
class DetailViewController: UIViewController {

    var dictDetail : NSDictionary?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblOverview: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var detailView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        
        lblTitle.text = dictDetail!["title"] as? String
        lblOverview.text = dictDetail!["overview"] as? String
        lblOverview.sizeToFit()
        if ((dictDetail!["poster_path"] as? String) != nil)
        {
            loadImage()
        }
        else
        {
            self.imgMovie.image = nil
        }
        let contentWidth = scrollView.bounds.width
        //let contentHeight = scrollView.bounds.height * 3
        
        scrollView.contentOffset = CGPoint(x:0,y:-detailView.frame.size.height)
        scrollView.contentSize = CGSize(width: contentWidth, height: detailView.frame.size.height*2.1)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.title = ""

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadImage(){
        
        let smallImageUrl = "https://image.tmdb.org/t/p/w45\(dictDetail!["poster_path"] as! String)"
        let largeImageUrl = "https://image.tmdb.org/t/p/original\(dictDetail!["poster_path"] as! String)"
        let smallImageRequest = URLRequest(url: URL(string: smallImageUrl)!)
        let largeImageRequest = URLRequest(url: URL(string: largeImageUrl)!)
        
        self.imgMovie.setImageWith(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
                self.imgMovie.alpha = 0.0
                self.imgMovie.image = smallImage;
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    self.imgMovie.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.imgMovie.setImageWith(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.imgMovie.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
        })
    }
    
    

}
