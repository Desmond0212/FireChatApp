//
//  RegistrationViewController.swift
//  FireChatApp
//
//  Created by DesmondWong on 26/12/2019.
//  Copyright © 2019 DesmondWong. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController
{
    func HideKeyboardSignUp()
    {
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    
    @objc func DismissKeyboar()
    {
        view.endEditing(true)
        view.frame.origin.y = 0
    }
}

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var messageViewController: LandingViewController?
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "add-profile-image7")
        iv.layer.cornerRadius = 16
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        return iv
    }()
    
    let uploadImageLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to upload profile image"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        
        return label
    }()
    
    lazy var emailContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "baseline_mail_outline_white_36pt_3x"), emailTextField)
    }()
    
    lazy var usernameContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "baseline_person_white_24pt_2x"), usernameTextField)
    }()
    
    lazy var passwordContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "baseline_lock_white_24pt_3x"), passwordTextField)
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceHolder: "Email", isSecureTextEntry: false)
    }()
    
    lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceHolder: "Username", isSecureTextEntry: false)
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceHolder: "Password", isSecureTextEntry: true)
    }()
    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureViewComponents()
        
        //To dismiss keyboard.
        self.HideKeyboardSignUp()
        
        //Listener for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow/*UIResponder.keyboardWillShowNotification*/, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide/*UIResponder.keyboardWillHideNotification*/, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame/*UIResponder.keyboardWillChangeFrameNotification*/, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //Open Galary to Select Image.
    @objc func requestSelectImage()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker
        {
            logoImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //stop listener for keyboard show/hide events.
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow/*UIResponder.keyboardWillShowNotification*/, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide/*UIResponder.keyboardWillHideNotification*/, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame/*UIResponder.keyboardWillChangeFrameNotification*/, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification)
    {
        print("Keyboard will show: \(notification.name.rawValue)")
        
        view.frame.origin.y = -70
    }
    
    @objc func handleSignUp()
    {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        
        createUser(withEmail: email, password: password, username: username)
    }
    
    @objc func handleShowLogin()
    {
//        let loginController = LoginViewController()
//        self.present(loginController, animated: true, completion: nil)
        //navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func createUser(withEmail email: String, password: String, username: String)
    {
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if (error != nil)
            {
                print("Failed to sign user up with error: ", error!.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            //When Successfully Authenticated User
            let imageName = NSUUID().uuidString
            //let storageRef = Storage.storage().reference().child("profileImages").child("\(imageName).png")
            let storageRef = Storage.storage().reference().child("profileImages").child("\(imageName).jpg")
            
            if let profileImage = self.logoImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1)
            {
                storageRef.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                    if (error != nil)
                    {
                        print(error!)
                        return
                    }
                    else
                    {
                        print(metadata!)
                        storageRef.downloadURL(completion: { (url, err) in
                            if let err = err
                            {
                                print(err)
                                return
                            }
                            
                            guard let url = url else { return }
                            let values = ["Username": username, "Email": email, "ProfileImageUrl": url.absoluteString, "Password": password]
                            
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        })
                    }
                })
            }
            
            /*let values = ["email": email, "username": username]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error
                {
                    print("Failed to update database values with error: ", error.localizedDescription)
                    return
                }
                
                guard let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
                guard let controller = navController.viewControllers[0] as? LandingViewController else { return }
                
                /*controller.configureViewComponents()*/
                
                // forgot to add this in video
                /*controller.loadUserData()*/
                
                self.dismiss(animated: true, completion: nil)
            })*/
        }
    }
    
    func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject])
    {
        //When Successfully Created User to Firebase Database.
        let ref = Database.database().reference()//(fromURL: "https://swiftchattingapp.firebaseio.com/")
        let usersReference = ref.child("Users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: {(err, ref) in
            if (err != nil)
            {
                print (err!)
                return
            }
            else
            {
                print ("Successfully Saved User to Firebase Database!")
                
                let user = User(dictionary: values)
                self.messageViewController?.setupNavBarWithUser(user: user)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func configureViewComponents()
    {
        view.backgroundColor = UIColor.mainBlue()
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 80, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(requestSelectImage)))
        logoImageView.isUserInteractionEnabled = true
        
        view.addSubview(uploadImageLabel)
        uploadImageLabel.anchor(top: logoImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        uploadImageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: uploadImageLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(usernameContainerView)
        usernameContainerView.anchor(top: emailContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(passwordContainerView)
        passwordContainerView.anchor(top: usernameContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(loginButton)
        loginButton.anchor(top: passwordContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        //        view.addSubview(dividerView)
        //        dividerView.anchor(top: loginButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        //
        //        view.addSubview(googleLoginButton)
        //        googleLoginButton.anchor(top: dividerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 50)
    }
}