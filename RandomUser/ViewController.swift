//
//  ViewController.swift
//  RandomUser
//
//  Created by Peiyun on 2022/11/17.
//

import UIKit
//加入音效
import AudioToolbox

struct User{
    var name:String?
    var gender:String?
    var email:String?
    var number:String?
    var image:String?
    var country:String?
    var state:String?
    var city:String?
    var street:String?
}

/*解析JSON
建立一個struct來模仿資料結構
模仿資料結構的秘訣：
1.字典需要加入新的結構模仿，其他不用
2.需要的資料才需要模仿，不需要的資料不用管
3.模仿資料的屬性要跟key的名稱一樣
*/

//第一層
struct AllData:Decodable{
    var results:[SingleData]?
}

//第二層
struct SingleData:Decodable{
    var name:Name?
    var gender:String?
    var location:Location?
    var email:String?
    var phone:String?
    var picture:Picture?
}

//第三層
struct Name:Decodable{
    var first:String?
    var last:String?
}

struct Picture:Decodable{
    var large:String?
}


struct Location:Decodable{
    var country:String
    var state:String?
    var city:String?
    var street:Street?
}

//第四層
struct Street:Decodable{
    var number:Int?
    var name:String?
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    //定義變數，使InfoTableViewController可連結過來
    var infoTableViewController:InfoTableViewController?
    //導入網址
    let apiAddress = "https://randomuser.me/api/"
    //產生URLSession的物件
    var urlSession = URLSession(configuration: .default)
    //為了避免按下按鈕時尚在下載，先建立一個屬性 並在各方法間註明是否下載結束
    var isDownloading = false
    
    @IBAction func makeNewUser(_ sender: UIBarButtonItem) {
        if isDownloading == false{
            downloadInfo(withAddress: apiAddress)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        /*設定假資料
        let aUser = User(name: "Amy", gender: "male",email:"apple.gmail.com", number:"012-345678", image: "http://picture.me",country: "Taiwan",state: "none", city: "Taipei", street: "300 local")
        settingInfo(user: aUser)
        */
        
        downloadInfo(withAddress: apiAddress)
        
    }
    
    //導入資料
    func settingInfo(user:User){
        userName.text = user.name
        //連結完TableViewController後可將資料導入
        infoTableViewController?.genderLabel.text = user.gender
        infoTableViewController?.phoneLabel.text = user.number
        infoTableViewController?.emailLabel.text = user.email
        infoTableViewController?.countryLabel.text = user.country
        infoTableViewController?.stateLabel.text = user.state
        infoTableViewController?.cityLabel.text = user.city
        infoTableViewController?.streetLabel.text = user.street
        
        //下載使用者圖片(使用Download Task)
        if let imageAddress = user.image{
            if let imageURL = URL(string: imageAddress){
                let task = urlSession.downloadTask(with: imageURL) { url, response, error in
                    if error != nil{
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "Sorry1")
                        }
                        self.isDownloading = false
                        return
                    }
                    if let okURL = url{
                        do{
                           let DownloadImage = UIImage(data: try Data(contentsOf: okURL))
                            DispatchQueue.main.async{
                                self.userImage.image = DownloadImage
                                AudioServicesPlaySystemSound(1000)
                            }
                            self.isDownloading = false
                        }catch{
                            DispatchQueue.main.async {
                                self.popAlert(withTitle: "Sorry2")
                            }
                            self.isDownloading = false
                        }
                    }else{
                        self.isDownloading = false
                    }
                }
                task.resume()
            }else{
                //如果無法成功把地址轉換成url，標示下載結束
                isDownloading = false
            }
        }else{
            //如果無法拿到圖片網址，標示下載結束
            isDownloading = false
        }
    }
    
    //連結TableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreinfo"{
            infoTableViewController = segue.destination as? InfoTableViewController
        }
    }
    

    
    //用URLSession連結網路服務
    func downloadInfo(withAddress webAddress:String){
        if let url = URL(string: webAddress){
            let task = urlSession.dataTask(with: url) { data, response, error in
                if error != nil{
                    let errorcode = (error! as NSError).code
                    if errorcode == -1009{
                        //因警告控制器跟畫面有關，故回到主佇列
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "No Internet Connection")
                        }
                    }else{
                        DispatchQueue.main.async{
                            self.popAlert(withTitle: "Sorry3")
                        }
                    }
                    self.isDownloading = false
                    return
                }
                if let loadedData = data {
                    do{
                        let okData = try JSONDecoder().decode(AllData.self, from: loadedData)
                        let firstName = okData.results?[0].name?.first
                        let lastName = okData.results?[0].name?.last
                        //建立一個closure, ():執行
                        let fullName:String? = {
                            guard let okFirstName = firstName, let okLastName = lastName else {
                                return nil }
                            return okFirstName + " " + okLastName
                        }()
                        
                        let email = okData.results?[0].email
                        let phone = okData.results?[0].phone
                        let picture = okData.results?[0].picture?.large
                        
                        let gender = okData.results?[0].gender
                        
                        let country = okData.results?[0].location?.country
                        let state = okData.results?[0].location?.state
                        let city = okData.results?[0].location?.city
                        let streetNumber = okData.results?[0].location?.street?.number
                        let streetName = okData.results?[0].location?.street?.name
                        let fullStreet:String? = {
                            guard let okStreetNumber = streetNumber, let okStreetName = streetName else{
                                return nil
                            }
                            return "\(okStreetNumber)" + " " + okStreetName
                        }()
                        
                        //產生資料
                        let aUser = User(name: fullName, gender: gender, email:email, number:phone, image: picture, country: country, state: state, city: city, street: fullStreet)
                        DispatchQueue.main.async {
                            self.settingInfo(user: aUser)
                        }
                            self.isDownloading = false
                    }catch{
                        DispatchQueue.main.async{
                            self.popAlert(withTitle: "Sorry4")
                        }
                        //如果解碼有錯，標示下載結束
                        self.isDownloading = false
                    }
                    
                }else{
                    //如果真的沒有data，標示下載結束
                    self.isDownloading = false
                }
            }
            task.resume()
            isDownloading = true
        }
    }
    
    
    
    //加入顯示錯誤的警告控制器
    func popAlert(withTitle title:String){
        let alert = UIAlertController(title: title, message: "please try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //圖片導圓角
    override func viewDidAppear(_ animated: Bool) {
        //不在viewDidLoad()做的原因為畫面大小此時尚未完全確定，讀入時會產生誤差。使用viewDidAppear這方法是畫面已顯示在螢幕上才會執行
        userImage.layer.cornerRadius = userImage.frame.size.width/2
        userImage.clipsToBounds = true
    }


}

