//
//  RegistroViewController.swift
//  EscobarSnapchat
//
//  Created by Mac20 on 10/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegistroViewController: UIViewController {

    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func RegistrarTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: {(user,error) in print("Intentando crear un usuario.")
            if error != nil {
                print("Se presento el error al crear el usuario:\(error)")
            }else{
                print("El usuario se creo correctamente")
                
                Database.database().reference().child("usuario").child(user!.user.uid).child("email").setValue(user!.user.email)
                
                let alerta = UIAlertController(title: "Cracion de usuario", message: "Usuario: \(self.emailTextField.text!) se creo correctamente.", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                    self.performSegue(withIdentifier: "registrarusuariosegue", sender: nil)
                })
                alerta.addAction(btnOK)
                self.present(alerta, animated: true, completion: nil)
                
            }
        })
    }
    

}
