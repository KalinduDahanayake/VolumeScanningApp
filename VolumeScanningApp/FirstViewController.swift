//
//  FirstViewController.swift
//  DistanceCalculator
//
//  Created by Kalindu Dahanyake on 23/1/22.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var lengthField: UITextField!
    @IBOutlet weak var widthField: UITextField!
    @IBOutlet weak var heightField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
        
    func sendValues(_ value: Float, _ type: String) {
      //override the label with the parameter received in this method
        if (type == "Length") {
            lengthField.text = "\(value)"
        }
        
        else if (type == "Width") {
            widthField.text = "\(value)"
        }
        
        else {
            heightField.text = "\(value)"
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MeasureObjectViewController
        destination.passingValue = segue.identifier!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
