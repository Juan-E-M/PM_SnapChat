//
//  RegistroViewController.swift
//  EscobarSnapchat
//
//  Created by Juan E. M. on 10/06/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class RegistroViewController: UIViewController {
    
    @IBOutlet weak var usuarioTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func crercuentaTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.usuarioTextField.text!, password: self.passwordTextField.text!, completion:{(user, error) in
            print("Intentando crear usuario")
            if error != nil{
                print("Se presento el siguiente error al crear al usuario: \(error)")
            }else{
                print("El usuario fue creado exitosamente")
                Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                let alerta = UIAlertController(title: "Creación de usuario", message: "Usuario: \(self.usuarioTextField.text!) se creo correctamente.", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                    self.performSegue(withIdentifier: "logeocuentacreadasegue", sender: nil)
                    })
                        alerta.addAction(btnOK)
                        self.present(alerta, animated: true, completion: nil)
            }
        })
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
