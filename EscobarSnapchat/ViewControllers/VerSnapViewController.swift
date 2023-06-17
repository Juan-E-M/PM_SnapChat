//
//  VerSnapViewController.swift
//  EscobarSnapchat
//
//  Created by Mac20 on 14/06/23.

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import AVFoundation

class VerSnapViewController: UIViewController {
    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var lblAudio: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var reproducirButton: UIButton!
    
    var player: AVPlayer?
    var timer: Timer?
    var startTime: Date?
    
    var snap = Snap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMensaje.text = "Mensaje: " + snap.descrip
        lblAudio.text = "Audio: " + snap.audioNombre
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        guard let audioURL = URL(string: snap.audioURL) else {
            mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al reproducir el audio", accion: "Aceptar")
            return
        }
        
        player = AVPlayer(url: audioURL)
        player?.play()
        
        startTimer()
    }
    
    func startTimer() {
        startTime = Date()
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimerLabel()
        }
    }
    
    func updateTimerLabel() {
        guard let startTime = startTime else {
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        lblTimer.text = timeString
    }
    
    @objc func playerDidFinishPlaying() {
        timer?.invalidate()
        lblTimer.text = "00:00"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Database.database().reference().child("usuario").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jpg").delete{
            (error) in
            print("Se elimino la imagen correctamente")
        }
        Storage.storage().reference().child("audios").child("\(snap.audioID).m4a").delete{
            (error) in
            print("Se elimino el audio correctamente")
        }
        timer?.invalidate()
        player?.pause()
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnAceptar = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnAceptar)
        present(alerta, animated: true, completion: nil)
    }
}
