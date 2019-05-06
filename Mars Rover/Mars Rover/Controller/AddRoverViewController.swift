//
//  AddRoverViewController.swift
//  Mars Rover
//
//  Created by Antonio Yip on 6/05/19.
//

import UIKit

class AddRoverViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var positionPicker: UIPickerView!
    
    @IBAction func donButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text,
            let x = pickerData[0][selectedPickerData[0]] as? Int,
            let y = pickerData[1][selectedPickerData[1]] as? Int,
            let heading = pickerData[2][selectedPickerData[2]] as? Heading
        else {
            return
        }
        
        let newRover = Rover(name: name, position: Position(coordinate: Coordinate(x: x, y: y), heading: heading))
        mainVC.site.rovers.append(newRover)
        
        dismiss(animated: true) {
            self.mainVC.selectedRover = newRover
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    lazy var pickerData: [[Any]] = [
        [Int](0 ..< mainVC.site.grid.x),
        [Int](0 ..< mainVC.site.grid.y),
        [Heading.N, Heading.E, Heading.S, Heading.W]
    ]
    
    var selectedPickerData: [Int] = Array.init(repeating: 0, count: 3)
    
    weak var mainVC: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        nameTextField.text = "Rover \(mainVC.site.rovers.count + 1)"
        
        positionPicker.dataSource = self
        positionPicker.delegate = self
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

}

extension AddRoverViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddRoverViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(describing: pickerData[component][row])
    }
}

extension AddRoverViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerData[component] = row
    }
}
