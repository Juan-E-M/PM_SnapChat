//
//  ViewController.swift
//  EscobarSnapchat
//
//  Created by Juan E. M. on 31/05/23.
//

import UIKit

import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseDatabase

class iniciarSessionViewController: UIViewController {
    
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){(user, error) in
            print("Intentando Iniciar Sesion")
            if error != nil {
                let alerta = UIAlertController(title: "Falló el inicio de sesión", message: "El Usuario o contraseña son inválidas", preferredStyle: .alert)
                                let btnCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                                let btnCrear = UIAlertAction(title: "Crear", style: .default, handler: {(UIAlertAction) in
                                    self.performSegue(withIdentifier: "registrarvistasegue", sender: nil)
                                    })
                                alerta.addAction(btnCancelar)
                                alerta.addAction(btnCrear)
                                self.present(alerta, animated: true, completion: nil)
                print("Se presento el siguiente error: \(error)")
                
            }else {
                print("Inicio de sesion exitoso")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
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

