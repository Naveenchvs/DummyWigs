//
//  ViewController.swift
//  WigsClick
//
//  Created by Saraschandra on 09/11/17.
//  Copyright © 2017 Mobiware. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,PhotoFinalizedVCDelegate
{

    @IBOutlet var ContainerView: UIView!
    
    @IBOutlet var maniqueneImageView: UIImageView!
    
    @IBOutlet var wigsTableView: UITableView!
    
    @IBOutlet var uploadImageBtn: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var image : UIImage!
        image = UIImage(named: "Select")
        print(image.size)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func uploadImageBtnAction(_ sender: Any)
    {
        let actionSheetController = UIAlertController(title: "Take Image", message: "From Were You Want To Upload", preferredStyle: .actionSheet)
        
        //Camera Action Button
        let cameraActionButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        actionSheetController.addAction(cameraActionButton)
        
        //Photo Library Action Button
        let libraryActionButton = UIAlertAction(title: "Photo Library", style: .default) { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }

        }
        actionSheetController.addAction(libraryActionButton)
        
        
        //Cancel Action Button
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            dismiss(animated:true, completion: nil)
            
            let photoFinalizedVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoFinalizedViewController") as! PhotoFinalizedVC
            photoFinalizedVC.delegate = self
            photoFinalizedVC.capturedImage = image
            print("Captured Image Size Before Scaling \(image.size)")
        
            self.navigationController?.pushViewController(photoFinalizedVC, animated: true)
            
        }
        else
        {
            print("Something Went Wrong")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated:true, completion: nil)
    }
    
    
    //PhotoFinalizedVCDelegate Method
    func setCropedImage(_ image: UIImage!)
    {
        self.maniqueneImageView.image = image
        print("Selected ImageView Scale is \(String(describing: self.maniqueneImageView.image?.scale))")
        print("Selected image size is \(String(describing: self.maniqueneImageView.image?.size))")
        print("Selected imageView size is \(String(describing: self.maniqueneImageView.frame.size))")
    }

   
}

