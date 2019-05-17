//
//  ViewController.swift
//  Snacktacular


import UIKit
import CoreLocation
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn

class SpotsListViewController: UIViewController {
    var spots: Spots!
    
    //for sign-in
    var authUI: FUIAuth!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for sign-in
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        //tableView stuff
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true //don't show tableView when user presses cancel (didn't sign-in)
        
        spots = Spots()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        spots.loadData {
            self.tableView.reloadData()
        }
    }
    
    //for sign-in
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    func signIn(){
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            //FUIFacebookAuth(), //see "Easily add sign-in to your iOS...."
            //FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
        ]
        if authUI.auth?.currentUser == nil{
            self.authUI.providers = providers
            present(authUI.authViewController(),animated: true,completion: nil)
        }else{
            tableView.isHidden = false
        }
    }
    
    //To pass over data to SpotDetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSpot" { //CLICKED CELL
            let destination = segue.destination as! SpotDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.spot = spots.spotArray[selectedIndexPath.row]
        }else{//CLICKED ADD BUTTON
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    
    //for sign-out account
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try  authUI!.signOut()
            print("sign-out sucess")
            tableView.isHidden = true //don't show tableview when signed out
            signIn()
        }catch{
            print("Error signing out")
        }
    }
    //end of class
}


//tableview
extension SpotsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.spotArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SpotsTableViewCell
        cell.nameLabel.text = spots.spotArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}


//for sign-in
extension SpotsListViewController: FUIAuthDelegate{
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user{
            tableView.isHidden = false //reveal tableview when signed in
            print("Sign-in with user\(user.email ?? "unknown e-mail")")
        }
    }
    
    //logo in sign-in page
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.white
        let marginInsets: CGFloat = 16
        let imageHeight: CGFloat = 225
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (2 * marginInsets), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFill
        loginViewController.view.addSubview(logoImageView)
        return loginViewController
    }
}
