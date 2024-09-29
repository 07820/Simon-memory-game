​
3500855825@qq.com
​
//

//  models.swift

//  UserLocation

//

//  Created by Xu, Yanqi on 08/12/2023.

//





import Foundation



//MARK: struct Plant



struct Plant: Codable {

   

    var recnum: String

    

    var acid:  String

    var accsta:String

    var family:String

    var genus:String

    var species:String

    var infraspecific_epithet:String

    var vernacular_name:String

    var cultivar_name:String

    var donor:String

    var latitude:String

    var longitude:String

    var country:String

    var iso:String

    var sgu:String

    var loc:String

    var alt:String

    var cnam:String

    var cid:String

    var cdat:String

    var bed:String

    var memoriam:String

    var redlist: String?

    var last_modified:String

    

//Transfer bed to array

    var bedArray: [String] {

            return bed.components(separatedBy: .whitespaces)

        }

}





//MARK: struct Image

struct Image: Codable {

    var recnum: String

    var imgid: String

    var img_file_name: String

    var imgtitle:String

    var photodt:String

    var photonme:String

    var copy:String

    var last_modified:String

    

    //Generate thumbnail url

    var thumbnailUrl: String {

            return "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_thumbnails/" + img_file_name

        }

}









//MARK: struct Bed

struct Bed: Decodable {

    var bed_id: String

    var name: String?

    var latitude: String

    var longitude: String

    var last_modified:String

}







struct BedsResponse: Decodable {

    var beds: [Bed]

}



struct PlantsResponse: Decodable {

    var plants: [Plant]

}

 

struct ImageResponse: Codable {

    var images: [Image]

}






//

//  NetworkService.swift

//  UserLocation

//

//  Created by Xu, Yanqi on 04/12/2023.

//



// NetworkService.swift



import Foundation



class NetworkService {

    static let shared = NetworkService()



    private init() {}



    func fetchBeds(completion: @escaping (BedsResponse?) -> Void) {

        let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=beds")!

        fetchData(url: url, completion: completion)

    }



    func fetchPlants(completion: @escaping (PlantsResponse?) -> Void) {

        let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=plants")!

        fetchData(url: url, completion: completion)

    }

    

    func fetchImages(completion: @escaping ([Image]?) -> Void) {

        let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness/data.php?class=images")!

        fetchData(url: url) { (response: ImageResponse?) in

            completion(response?.images)

        }

    }



    

    

    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {

        

        URLSession.shared.dataTask(with: url) { data, response, error in

            //check potential errors in data

            guard let data = data, error == nil else {

                print("No data or there was an error: \(String(describing: error))")

                completion(nil)

                return

            }

            let decoder = JSONDecoder()

            

            

            do {

                

               //Analyse data or return nil

                let result = try decoder.decode(T.self, from: data)

                completion(result)

            } catch {

                print("Error decoding JSON: \(error)")

                completion(nil)

            }

        }.resume()

    }





    

    

    

}




//

//  ImageLoader.swift

//  UserLocation

//

//  Created by Xu, Yanqi on 06/12/2023.

//



import Foundation





import UIKit





class ImageLoader {



    static func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {

        

        //Transfer String to url or return nil

        guard let url = URL(string: urlString) else {

            print("invail URL: \(urlString)")

            

            DispatchQueue.main.async {

                completion(nil)

            }

            return

        }



        //create dataTask to load image

        URLSession.shared.dataTask(with: url) { data, response, error in

            

            if let data = data, let image = UIImage(data: data) {

                completion(image)

            } else {

                print("load error")

                completion(nil)

            }

            

            

            

        }.resume()

    }



}






//

//  ViewController.swift

//  UserLocation

//

//  Created by Phil Jimmieson on 20/11/2022.

//



import UIKit

import MapKit



class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    

    

    // MARK: Map & Location related stuff

    

    @IBOutlet weak var myMap: MKMapView!

    

    var locationManager = CLLocationManager()

    

    var firstRun = true

    var startTrackingTheUser = false

    

    var currentUserLocation: CLLocation?

    var images = [Image]()

    

    

    //Calculate the distance between the user and the beds

    func distanceFromUser(to bed: Bed, userLocation: CLLocation) -> CLLocationDistance {

        guard let bedLatitude = Double(bed.latitude), let bedLongitude = Double(bed.longitude) else {

            return Double.greatestFiniteMagnitude

        }

        let bedLocation = CLLocation(latitude: bedLatitude, longitude: bedLongitude)

        return bedLocation.distance(from: userLocation)

    }

    

    //Sort beds according to distance from users

    func sortBedsByDistance() {

        guard let currentUserLocation = currentUserLocation else { return }



        beds.sort { (bed1, bed2) -> Bool in

            return distanceFromUser(to: bed1, userLocation: currentUserLocation) < distanceFromUser(to: bed2, userLocation: currentUserLocation)

        }

    }

    

    

    //Update the table each time when user walk 8 meters

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        

        guard let location = locations.first else { return }

            

        

        

            if let oldLocation = currentUserLocation, oldLocation.distance(from: location) > 8 {

                currentUserLocation = location

                sortBedsByDistance()

                DispatchQueue.main.async {

                    self.theTable.reloadData()

                }

            } else if currentUserLocation == nil {

                currentUserLocation = location

                sortBedsByDistance()

                DispatchQueue.main.async {

                    self.theTable.reloadData()

                }

            }

        

        if firstRun {

            firstRun = false

            let latDelta: CLLocationDegrees = 0.0025

            let lonDelta: CLLocationDegrees = 0.0025

            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)

            let region = MKCoordinateRegion(center: location.coordinate, span: span)

            myMap.setRegion(region, animated: true)

            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startUserTracking), userInfo: nil, repeats: false)

        }



        if startTrackingTheUser {

            myMap.setCenter(location.coordinate, animated: true)

        }

    }

      @objc func startUserTracking() {

        startTrackingTheUser = true

    }

    

    //add beds location to the map

     func addBedsToMap() {

         for bed in beds {

             guard let latitude = Double(bed.latitude), let longitude = Double(bed.longitude) else {

                 continue

             }

             let annotation = MKPointAnnotation()

             annotation.title = bed.name

             annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

             myMap.addAnnotation(annotation)

         }

     }

     

    //MARK: Table related stuff

    var beds = [Bed]()

    var plants = [Plant]()

    

    @IBOutlet weak var theTable: UITableView!

    

    

    // return the number of beds as section number

    func numberOfSections(in tableView: UITableView) -> Int {

            

        let sectionCount = beds.count

       

            return beds.count

        }

    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let bedId = beds[section].bed_id

        let rowCount = plants.filter { $0.bed.contains(bedId) }.count

      

         return plants.filter { $0.bed.contains(bedId) }.count

    }

    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        var content = cell.defaultContentConfiguration()



        let bedId = beds[indexPath.section].bed_id

        let plant = plants.filter { $0.bedArray.contains(bedId) }[indexPath.row]



        //Set text info in cell

        cell.selectionStyle = .default

        content.text = "\(plant.genus) \(plant.species)"

        

        let subtitleParts = ["Family: \(plant.family)", "Vernacular: \(plant.vernacular_name)", "Cultivar: \(plant.cultivar_name)"]

        content.secondaryText = subtitleParts.joined(separator: ", ")

        

        

        //Display thumbnails with default cell imageview

        if let image = images.first(where: { $0.recnum == plant.recnum }) {

            print("find image：\(image.thumbnailUrl)")

            let currentIndexPath = indexPath

            ImageLoader.loadImage(from: image.thumbnailUrl) { downloadedImage in

                DispatchQueue.main.async {

                    if tableView.cellForRow(at: currentIndexPath) == cell {

                        content.image = downloadedImage

                        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)

                        cell.contentConfiguration = content

                    }

                }

            }

        } else {

            content.image = nil

        }



        

        cell.contentConfiguration = content

        return cell

    }

    

    //show bed name on the top

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

            return beds[section].name

        }

    

    func checkDataAndReloadTable() {

           

            if !beds.isEmpty && !plants.isEmpty {

                theTable.reloadData()

                addBedsToMap()

            }

        }



    // MARK: View related Stuff

    

    

    

 

    //Show new detail viewcontroller and pass data when user click the cell

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        

        let bedId = beds[indexPath.section].bed_id

        let plant = plants.filter { $0.bedArray.contains(bedId) }[indexPath.row]



       

        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "PlantDetailViewController") as? PlantDetailViewController {

            detailVC.plant = plant

            

            //Use recnum to march image

            let plantImages = images.filter { $0.recnum == plant.recnum }

            

            

              detailVC.images = plantImages

            

            navigationController?.pushViewController(detailVC, animated: true)

        }

        

        

    }

    

    override func viewDidLoad() {

        super.viewDidLoad()

        

        locationManager.delegate = self as CLLocationManagerDelegate

        

        

        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        

      

        locationManager.requestWhenInUseAuthorization()

        

       

        locationManager.startUpdatingLocation()

        

       

        myMap.showsUserLocation = true

        

        

    

        NetworkService.shared.fetchBeds { [weak self] bedsResponse in

            DispatchQueue.main.async {

                if let beds = bedsResponse?.beds {

                    self?.beds = beds

                    self?.checkDataAndReloadTable()

                    self?.addBedsToMap()

                }

            }

        }



     

        NetworkService.shared.fetchPlants { [weak self] plantsResponse in

            DispatchQueue.main.async {

                //Check if all plant's accsta is C

                if let plants = plantsResponse?.plants.filter({ $0.accsta == "C" }) {

                    self?.plants = plants

                    self?.checkDataAndReloadTable()

                }

            }

         

            

            

            NetworkService.shared.fetchImages { [weak self] imagesResponse in

                DispatchQueue.main.async {

                    if let images = imagesResponse {

                        self?.images = images

                        print("Fetched \(images.count) images.")

                       

                    } else {

                        print("Failed to fetch images.")

                    }

                }

            }



        }

    }

    

    

}




//

//  PlantDetailViewController.swift

//  UserLocation

//

//  Created by Xu, Yanqi on 05/12/2023.

//



import UIKit

import MapKit





class PlantDetailViewController: UIViewController {

  

   

    

    

    @IBOutlet weak var scrollView: UIScrollView!

    

    @IBOutlet weak var textView: UITextView!

    

    @IBOutlet weak var mapView: MKMapView!

    

    

    

    var images: [Image] = []

    

   var plant: Plant?

    

    // MARK: scrollView related Stuff

   // Set scrollView to show multi-images

    func displayImages() {

            guard !images.isEmpty else {

                print("No images available.")

                return

            }



            let imageWidth: CGFloat = self.scrollView.frame.size.width

            let imageHeight: CGFloat = self.scrollView.frame.size.height

            var xPosition: CGFloat = 0



            for image in images {

                

                //Splice URL of each plant‘s image

                let imageUrlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/ness_images/" + image.img_file_name

                

                let imgView = UIImageView(frame: CGRect(x: xPosition, y: 0, width: imageWidth, height: imageHeight))

                imgView.contentMode = .scaleAspectFit



                ImageLoader.loadImage(from: imageUrlString) { downloadedImage in

                    DispatchQueue.main.async {

                        imgView.image = downloadedImage

                    }

                }



                self.scrollView.addSubview(imgView)

                xPosition += imageWidth

            }

            //Set the size of scrollView

            scrollView.contentSize = CGSize(width: imageWidth * CGFloat(images.count), height: imageHeight)

        }





    override func viewDidLoad() {

        super.viewDidLoad()

        displayPlantDetails()

       

        displayImages()

    }



    // MARK: cellContent related Stuff

    func displayPlantDetails() {

        guard let plant = plant else { return }



       //Set the content of textView

        let details = """

                        Genus: \(plant.genus)

                        Species: \(plant.species)

                        acid: \(plant.acid)

                        accsta:\(plant.accsta)

                        family:\(plant.family)

                        infraspecific_epithet:\(plant.infraspecific_epithet)

                        vernacular_name:\(plant.vernacular_name)

                        cultivar_name:\(plant.cultivar_name)

                        donor:\(plant.donor)

                        latitude:\(plant.latitude)

                        longitude:\(plant.longitude)

                        country:\(plant.country)

                        iso:\(plant.iso)

                        sgu:\(plant.sgu)

                        loc:\(plant.loc)

                        alt:\(plant.alt)

                        cnam:\(plant.cnam)

                        cid:\(plant.cid)

                        cdat:\(plant.cdat)

                        bed:\(plant.bed)

                        memoriam:\(plant.memoriam)

                        redlist:\(String(describing: plant.redlist))

                        last_modified:\(plant.last_modified)

                   """

                  



        textView.text = details



    //Set the  original plant origin

        if let latitude = Double(plant.latitude), let longitude = Double(plant.longitude) {

            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            let annotation = MKPointAnnotation()

            annotation.coordinate = coordinate

            mapView.addAnnotation(annotation)

            mapView.centerCoordinate = coordinate

        } else {           

            //Hide the map if the latitude and longitude does not exist

            mapView.isHidden = true

        }

    }

}



