//
//  ImagenViewController.swift
//  EscobarSnapchat
//
//  Created by Mac20 on 7/06/23.
//

import UIKit
import FirebaseStorage
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
        configurarGrabacion()
    }
    
    //imagen
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var imagenID = NSUUID().uuidString
    var imagenURL = ""
    var imagePicker = UIImagePickerController()
    
    //audio
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    var audioID = NSUUID().uuidString
    var audioURL = ""
    var audioLocalURL:URL?
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    
    //audio funciones
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            elegirContactoBoton.isEnabled = true
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioLocalURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    //
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        
        //imagen
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let imagenData =  imageView.image?.jpegData(compressionQuality: 0.5)
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
        
        //audio
        let audiosFolder = Storage.storage().reference().child("audios")
        let audioData = try? Data(contentsOf: self.audioLocalURL!)
        let uploadAudio = audiosFolder.child("\(self.audioID).m4a")

        // Cargar imagen
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Ocurrió un error al subir imagen: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique ", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
            } else {
                cargarImagen.downloadURL(completion: { (url, error) in
                    if let url = url {
                        self.imagenURL = url.absoluteString
                        print("URL de la imagen subida: \(self.imagenURL)")
                    } else {
                        print("Ocurrió un error al obtener la URL de la imagen subida: \(error)")
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de la imagen", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                    }
                    dispatchGroup.leave()
                })
            }
        }

        // Cargar audio
        dispatchGroup.enter()
        uploadAudio.putData(audioData!, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Ocurrió un error al subir el audio: \(error)")
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir el audio. Verifique ", accion: "Aceptar")
            } else {
                uploadAudio.downloadURL { (url, error) in
                    if let url = url {
                        self.audioURL = url.absoluteString
                        print("URL del audio subido: \(self.audioURL)")
                    } else {
                        print("Ocurrió un error al obtener la URL del audio subido: \(error)")
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información del audio", accion: "Cancelar")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        // Esperando a que ambas promises se completen
        dispatchGroup.notify(queue: .main) {
            let senderURLS:  [String: Any] = ["urlImagen": self.imagenURL, "urlAudio":self.audioURL]
            print(senderURLS)
            self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: senderURLS)
        }

    }
    
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let senderDict = sender as? [String: Any] {
            let siguienteVC = segue.destination as! ElegirUsuarioViewController
            
            //imagen
            siguienteVC.imagenURL = senderDict["urlImagen"] as? String ?? ""
            siguienteVC.descrip = descripcionTextField.text!
            siguienteVC.imagenID = imagenID
            
            //audio
            siguienteVC.audioNombre = nombreTextField.text!
            siguienteVC.audioID = audioID
            siguienteVC.audioURL = senderDict["urlAudio"] as? String ?? ""
            }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion:String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCELOK = UIAlertAction(title: accion, style: .default,handler: nil)
        alerta.addAction(btnCANCELOK)
        present(alerta, animated: true,completion: nil)
    }
    
    
    //funciones para subir el audio
    func configurarGrabacion(){
           do{
               let session = AVAudioSession.sharedInstance()
               try session.setCategory(AVAudioSession.Category.playAndRecord, mode:AVAudioSession.Mode.default, options: [])
               try session.overrideOutputAudioPort(.speaker)
               try session.setActive(true)

               let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).first!
               let pathComponents = [basePath,"audio.m4a"]
               audioLocalURL = NSURL.fileURL(withPathComponents: pathComponents)!

               var settings:[String:AnyObject] = [:]
               settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
               settings[AVSampleRateKey] = 44100.0 as AnyObject?
               settings[AVNumberOfChannelsKey] = 2 as AnyObject?

               grabarAudio = try AVAudioRecorder(url:audioLocalURL!, settings: settings)
               grabarAudio!.prepareToRecord()
           }catch let error as NSError{
               print(error)
           }
        }
}
