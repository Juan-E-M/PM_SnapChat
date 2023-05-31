//
//  ViewController.swift
//  EscobarSnapchat
//
//  Created by Juan E. M. on 31/05/23.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class iniciarSessionViewController: UIViewController {
    
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){(user, error) in
            print("Intentando Iniciar Sesion")
            if error != nil {
                print("Se presento el siguiente error: \(error)")
            }else {
                print("Inicio de sesion exitoso")
            }
        }
    }
    
    
    
    
    
    @IBAction func sesionGoogleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {[unowned self] result, error in
            guard error == nil else {
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Ocurrió un error: \(error)")
                    return
                } else {
                    print("Logeo por Google de forma correcta")
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuration for google auth
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
       
    }
  


}

