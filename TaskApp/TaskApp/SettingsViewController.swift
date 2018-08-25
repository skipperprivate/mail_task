import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var switch_btn: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        
        let show_image = defaults.bool(forKey: "Show_image")
        
        if (show_image == true){
            switch_btn.isOn = true
        } else{
            switch_btn.isOn = false
        }
        
        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func turn_on_off(_ sender: UISwitch) {
        
        let defaults = UserDefaults.standard
        
        if (sender.isOn == true){
            
            //let defaults = UserDefaults.standard
            defaults.set(true, forKey: "Show_image")
            
        } else{
            
            defaults.set(false, forKey: "Show_image")
           // print("close")
            
        }
        
    }
    

}
