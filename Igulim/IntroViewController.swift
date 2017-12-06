import UIKit

class IntroViewController: UIViewController,OptimoveStateDelegate,DynamicLinkCallback {
    func didStartLoading() {
        
    }
    
    func didBecomeActive() {
        Optimove.sharedInstance.register(responder: DynamicLinkResponder(self))
    }
    
    func didBecomeInvalid(withErrors errors: [OptimoveError]) {
        
    }
    
    var id: Int = 0
    
    
    
    func didReceive(dynamicLink: DynamicLinkComponents) {
        switch dynamicLink.screenName {
        case "game":
           self.performSegue(withIdentifier: "goToGame", sender: nil)
        default:
            return
        }
    }
    
    
    private func setupHeader()
    {
        if let name = UserDefaults.standard.string(forKey: "customerName")
        {
            UIView.animate(withDuration: 0.4, animations: {
                
                self.loginButton.isHidden = true
                self.welcomeLabel.isHidden = false
                self.welcomeLabel.text = "Welcome \(name)"
            })
        }
        else
        {
            UIView.animate(withDuration: 0.4, animations: {
            self.loginButton.isHidden = false
            self.welcomeLabel.isHidden = true
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Optimove.sharedInstance.register(stateDelegate:self)
        setupHeader()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginButton.makeRound(withShadow: false)
        self.igulimView.makeRound(withShadow: false)
        self.redPlayerView.makeRound(withShadow: false)
        self.purplePlayerView.makeRound(withShadow: false)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Optimove.sharedInstance.unregister(responder: DynamicLinkResponder(self))
    }
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var igulimView: UIView!
    @IBOutlet weak var startGameButton: UIButton!
    {
        didSet
        {
            startGameButton.layer.cornerRadius = 8
            startGameButton.layer.shadowOffset = CGSize(width: 6, height: 6)
            startGameButton.layer.shadowColor = UIColor.black.cgColor
            startGameButton.layer.shadowRadius = 8
            startGameButton.layer.shadowOpacity = 1.0
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var redPlayerView: UIView!
    {
        didSet
        {
            redPlayerView.layer.shadowOffset = CGSize(width: 4, height: 4)
        }
    }
    @IBOutlet weak var purplePlayerView: UIView!
    {
        didSet
        {
            purplePlayerView.layer.shadowOffset = CGSize(width: 4, height: 4)
        }
    }
    @IBAction func userPressOnStart()
    {
        UIView.transition(with: startGameButton, duration: 0.4, options: .curveEaseOut, animations: {
            self.startGameButton.layer.shadowOffset = CGSize(width: 9, height: 9)
        }) { (_) in
            UIView.transition(with: self.startGameButton, duration: 0.4, options: .curveEaseOut, animations: {
                self.startGameButton.layer.shadowOffset = CGSize(width: 6, height: 6)
            },completion: nil)}
    }
    
    @IBAction func userPressOnLogin(_ sender: UIButton) {
        let alert = UIAlertController(title: "Let us know you",
                                      message: "Every date starts with names and emails exchanges, of course",
                                      preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Full Name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "example@example.com"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Welcome", style: .default, handler: { [weak alert] (_) in
            let name = alert?.textFields![0].text
            let email = alert?.textFields![1].text
            
            if let mail = email
            {
                if mail.isValidEmail()
                {
                    UserDefaults.standard.set(name, forKey: "customerName")
                    UserDefaults.standard.set(mail, forKey: "customerID")
                    UserDefaults.standard.synchronize()
                    Optimove.sharedInstance.set(userID: mail)
                    self.setupHeader()
                }
                else
                {
                    let mailAlert = UIAlertController(title: "Please enter a valid email",
                                                  message: nil,
                                                  preferredStyle: .alert)
                    mailAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (_) in
                        mailAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(mailAlert, animated: true, completion: nil)
                }
            }
        }))
        
        self.present(alert, animated: true,completion: nil)
       
        
    }
    
}

extension UIView
{
    func makeRound(withShadow :Bool)
    {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = !withShadow
    }
}

extension String
{
     func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
