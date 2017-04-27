//
//  DataRequests.swift
//  BirdBlox
//
//  Created by birdbrain on 4/27/17.
//  Copyright © 2017 Birdbrain Technologies LLC. All rights reserved.
//

import Foundation
import Swifter

class SoundRequests: NSObject {

    let audio_manager: AudioManager
    
    override init(){
        audio_manager = AudioManager()
        super.init()
    }
    
    func loadRequests(server: inout HttpServer){
        server["/sound/names"] = namesRequest(request:)
        server["/sound/stop_all"] = stopAllRequest(request:)
        server["/sound/stop"] = stopRequest(request:)

        
        server["/sound/duration/:filename"] = durationRequest(request:)
        server["/sound/play/:filename"] = playRequest(request:)
        server["/sound/note/:note_num/:duration"] = noteRequest(request:)
        
        
        
        //TODO: This is hacky. For some reason, some requests don't
        // want to be pattern matched to properly
        let old_handler = server.notFoundHandler
        server.notFoundHandler = {
            r in
            if r.path == "/sound/names" {
                return self.namesRequest(request: r)
            } else if r.path == "/sound/stop_all" {
                return self.stopAllRequest(request: r)
            } else if r.path == "/sound/stop" {
                return self.stopRequest(request: r)
            }
            if let handler = old_handler{
                return handler(r)
            } else {
                return .notFound
            }
        }
    }
    
    func namesRequest(request: HttpRequest) -> HttpResponse {
        let soundList = audio_manager.getSoundNames()
        var sounds: String = "";
        soundList.forEach({ (string) in
            sounds.append(string)
            sounds.append("\n")
        })
        return .ok(.text(sounds))
    }
    
    func stopAllRequest(request: HttpRequest) -> HttpResponse {
        self.audio_manager.stopTones()
        self.audio_manager.stopSounds()
        return .ok(.text("Sounds All Audio"))
    }
    
    func stopRequest(request: HttpRequest) -> HttpResponse {
        self.audio_manager.stopSounds()
        return .ok(.text("Sounds Stopped"))
    }
    
    func durationRequest(request: HttpRequest) -> HttpResponse {
        let filename = request.params[":filename"]!
        return .ok(.text(String(self.audio_manager.getSoundDuration(filename: filename))))
    }
    
    func playRequest(request: HttpRequest) -> HttpResponse {
        let filename = request.params[":filename"]!
        self.audio_manager.playSound(filename: filename)
        return .ok(.text("Playing sound"))
    }
    
    func noteRequest(request: HttpRequest) -> HttpResponse {
        let captured = request.params
        let note: UInt = UInt(captured[":note_num"]!)!
        let duration: Int = Int(captured[":duration"]!)!
        self.audio_manager.playNote(noteIndex: note, duration: duration)
        return .ok(.text("Playing Note"))
    }
    
}
