//
//  PhotoFinalizedVC.swift
//  WigsClick
//
//  Created by Saraschandra on 09/11/17.
//  Copyright © 2017 Mobiware. All rights reserved.
//

import UIKit

protocol PhotoFinalizedVCDelegate: class
{
    func setCropedImage(_ image: UIImage!)
}


class PhotoFinalizedVC: UIViewController,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
   
    @IBOutlet var maniqueneImageView: UIImageView!
    @IBOutlet var croppingView: UIView!
    @IBOutlet var referanceImageView: UIImageView!
    
    @IBOutlet var bottomView: UIView!
    
    var capturedImage : UIImage!
    
    var pinchIdentity = CGAffineTransform.identity
    
    var rotationalIdentity = CGAffineTransform.identity
    
    weak var delegate: PhotoFinalizedVCDelegate?
    
    var lastLocation = CGPoint()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveBtnAction))
        let cameraButton = UIBarButtonItem(title: "Click", style: .plain, target: self, action: #selector(cameraBtnAction))
        navigationItem.setRightBarButtonItems([saveButton,cameraButton], animated: true)
     
        self.view.backgroundColor = .white
        
        //self.setupManiqueneImageViewFrame()
        
        print("Before inserting image into ManiqueneImageView, frame size is\(self.maniqueneImageView.frame.size)")
        
        let resizedImage = resize(capturedImage, imageSize: maniqueneImageView.frame.size)
        
        print("Captured Image Size After Scaling \(resizedImage.size)")
        
        self.maniqueneImageView.image = resizedImage
        
        print("After inserting image into ManiqueneImageView, frame size is\(self.maniqueneImageView.frame.size)")
        
        print("Before Pinching ManiqueneImageView image scale is\(String(describing: self.maniqueneImageView.image?.scale))")
        
        print("Before Pinching ManiqueneImageView image scale in transform manner is \(String(describing: self.maniqueneImageView.transform))")
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scale))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
        
        pinchGesture.delegate = self
        rotationGesture.delegate = self
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(rotationGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            self.lastLocation = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let location = touch.location(in: self.view)
            
            self.maniqueneImageView.center = CGPoint(x:(location.x - self.lastLocation.x) + self.maniqueneImageView.center.x , y: (location.y - self.lastLocation.y) + self.maniqueneImageView.center.y)
            lastLocation = touch.location(in: self.view)
        }
    }
   
    func setupManiqueneImageViewFrame()
    {
        let maniqueneImageWidth: CGFloat = 240
        let maniqueneImageHeight: CGFloat = 400
        self.maniqueneImageView.frame = CGRect(x: view.frame.midX - maniqueneImageWidth / 2, y: view.frame.midY - maniqueneImageWidth / 2, width: maniqueneImageWidth, height: maniqueneImageHeight)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func scale(_ gesture: UIPinchGestureRecognizer)
    {
        switch gesture.state
        {
            case .began:
                  pinchIdentity = self.maniqueneImageView.transform
            case .changed:
                  self.maniqueneImageView.transform = pinchIdentity.scaledBy(x: gesture.scale, y: gesture.scale)
                  print("Pinch Gesture Scale \(gesture.scale)")
                  print("Pinch Gesture Transform \(maniqueneImageView.transform)")
                  print("When Pinching, the maniqueneImageView Image size is \(String(describing: maniqueneImageView.image?.size))")
                  print("When Pinching, the maniqueneImageView frame size is \(self.maniqueneImageView.frame.size)")
            
                  print("When Pinching ManiqueneImageView image scale is \(String(describing: self.maniqueneImageView.image?.scale))")
            case .ended:
                  break
            case .cancelled:
                  break
            default:
                  break
        }
    }
    func rotate(_ gesture: UIRotationGestureRecognizer)
    {
        switch gesture.state
        {
            case .began:
                  rotationalIdentity = self.maniqueneImageView.transform
            case .changed:
                  self.maniqueneImageView.transform = rotationalIdentity.rotated(by: gesture.rotation)
                  print("Rotational Gesture Scale \(gesture.rotation)")
                  print("Rotational Gesture Transform \(self.maniqueneImageView.transform)")
            case .ended:
                  break
            case .cancelled:
                  break
            default:
                  break
        }
    }
    
    func saveBtnAction()
    {
        let croppedImage = self.snapshot(of: croppingView.frame)
        print("CroppingView frame size is \(croppingView.frame.size)")
        print("After Croping cropped Image size is \(String(describing: croppedImage?.size))")
        print("After Croping cropped Image scale is \(String(describing: croppedImage?.scale))")
        self.referanceImageView.alpha = 1
        self.croppingView.alpha = 0.3
        if delegate != nil
        {
            self.navigationController?.popViewController(animated: true)
            delegate?.setCropedImage(croppedImage)
        }
        else
        {
            print("Delegate is nil")
        }
    }
    
    
    func snapshot(of rect: CGRect? = nil) -> UIImage?
    {
        self.referanceImageView.alpha = 0
        self.croppingView.alpha = 0
        // snapshot entire view
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 0)
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // if no `rect` provided, return image of whole view
        guard let image = wholeImage, let rect = rect else
        {
            return wholeImage
        }
        
        // otherwise, grab specified `rect` of image
        let scale = image.scale
        print("Snaped Scale is \(scale)")
        
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else
        {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
    func cameraBtnAction()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            dismiss(animated:true, completion: nil)
            //self.maniqueneImageView.image = image
            
            let resizedImage = resize(image, imageSize: maniqueneImageView.frame.size)
            self.maniqueneImageView.image = resizedImage
            
            print("After inserting image into ManiqueneImageView Through click, frame size is\(self.maniqueneImageView.frame.size)")
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
    
    func resize(_ image: UIImage, imageSize size: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // here is the scaled image which has been changed to the size specified
        UIGraphicsEndImageContext()
        return newImage!
    }
}

