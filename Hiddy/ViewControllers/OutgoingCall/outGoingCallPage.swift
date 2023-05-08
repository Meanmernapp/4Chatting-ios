//
//  outGoingCallPage.swift
//  Hiddy
//
//  Created by Hitasoft on 27/07/18.
//  Copyright © 2018 HITASOFT. All rights reserved.
//

import UIKit
import AVFoundation



class outGoingCallPage: UIViewController,callSocketDelegate {
    
    

    
    var peerConnection : RTCPeerConnection?
    var webRtcClient : RTCPeerConnectionFactory?
    
    
    let VIDEO_TRACK_ID = "VIDEO"
    let AUDIO_TRACK_ID = "AUDIO"
    let LOCAL_MEDIA_STREAM_ID = "STREAM"
    var senderFlag : Bool = true
    //stun server
    let stunServer : String = "stun:stun.l.google.com:19302"
    //streams
    var localMediaStream: RTCMediaStream!
    var localVideoTrack: RTCVideoTrack!
    var localAudioTrack: RTCAudioTrack!
    var remoteVideoTrack: RTCVideoTrack!
    var remoteAudioTrack: RTCAudioTrack!
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        callSocket.sharedInstance.delegate = self
        self.initalizeWebRTC()
        remoteView.isHidden = true

        // Do any additional setup after loading the view.
    }

    
    
    func gotCallSocketInfo(dict: NSDictionary, type: String)
    {
        if type == "join"
        {
            if (senderFlag)
            {
                let constraint = self.createAudioVideoConstraints()
                self.peerConnection?.add(localMediaStream)
                
                // create offer
                self.peerConnection?.createOffer(with: self, constraints: constraint)
            }
        }
        else if (type == "joined")
        {
            let dataDict = NSMutableDictionary()
            dataDict.setValue("Dinesh", forKey: "room")
            dataDict.setValue("got user media", forKey: "message")
            callSocket.sharedInstance.RTCMessage(requestDict: dataDict)
        }
        else if (type == "created")
        {
            let dataDict = NSMutableDictionary()
            dataDict.setValue("Dinesh", forKey: "room")
            dataDict.setValue("got user media", forKey: "message")
            callSocket.sharedInstance.RTCMessage(requestDict: dataDict)
        }
        else if(type == "rtcmessage")
        {
            print(dict)
            if (dict.object(forKey: "type") as! String == "offer")
            {
                if (!senderFlag)
                {
                    let rtcSessionDesc = RTCSessionDescription.init(type: dict.object(forKey: "type") as! String, sdp: dict.object(forKey: "sdp") as! String)
                    print(rtcSessionDesc.debugDescription)
                    //set remote description
                    self.peerConnection?.setRemoteDescriptionWith(self, sessionDescription: rtcSessionDesc!)
                    
                    //prepate connection
                    let constraint = self.createAudioVideoConstraints()
                    self.peerConnection?.add(localMediaStream)
                    
                    //send answer
                    self.peerConnection?.createAnswer(with: self, constraints: constraint)
                }
            }
            else if (dict.object(forKey: "type")as! String == "answer")
            {
                if (senderFlag)
                {
                    let rtcSessionDesc = RTCSessionDescription.init(type: dict.object(forKey: "type") as! String, sdp: dict.object(forKey: "sdp") as! String)
                    
                    // set remote description
                    self.peerConnection?.setRemoteDescriptionWith(self, sessionDescription: rtcSessionDesc!)
                }
            }
            else if(dict.object(forKey: "type")as! String == "candidate")
            {
                let candidate : RTCICECandidate = RTCICECandidate.init(mid: dict.object(forKey: "id") as! String, index: dict.object(forKey: "label") as! Int , sdp: dict.object(forKey: "candidate") as! String)
                self.peerConnection?.add(candidate)
            }
        }
    }
}

extension outGoingCallPage {
    
    //MARK: WebRTC Custom Methods
    
    func initalizeWebRTC() -> Void {
        
        RTCPeerConnectionFactory.initializeSSL()
        self.webRtcClient  = RTCPeerConnectionFactory.init()
        let stunServer = self.defaultStunServer()
        let defaultConstraint = self.createDefaultConstraint()
        self.peerConnection = self.webRtcClient?.peerConnection(withICEServers: [stunServer], constraints: defaultConstraint, delegate: self)
        
        self.localView.delegate = self
        self.remoteView.delegate = self
        // webrtc initalized local rendering of video on
        
        callSocket.sharedInstance.createOrJoin(chatId: "Dinesh")
        self.addLocalMediaStrem()
        
    }
    
    func addLocalMediaStrem() -> Void {
        
        var device: AVCaptureDevice! = nil
        if #available(iOS 10.0, *) {
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        } else {
            // Fallback on earlier versions
            for captureDevice in AVCaptureDevice.devices(for: AVMediaType.video) {
                if ((captureDevice as AnyObject).position == AVCaptureDevice.Position.front) {
                    device = captureDevice
                }
            }
            
        }
        
        // let audioDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInMicrophone, mediaType: AVMediaTypeAudio, position: .unspecified)
        if (device != nil) {
            let capturer = RTCVideoCapturer(deviceName: device.localizedName)
            
            //            let videoConstraints = RTCMediaConstraints()
            //            var audioConstraints = RTCMediaConstraints()
            
            let videoSource = self.webRtcClient?.videoSource(with: capturer, constraints: nil)
            localVideoTrack = self.webRtcClient?.videoTrack(withID: VIDEO_TRACK_ID, source: videoSource)
            // to implemet audio source in future
            //  let audioSource = self.webRtcClient?.aud
            localAudioTrack = self.webRtcClient?.audioTrack(withID: AUDIO_TRACK_ID)
            
            localMediaStream = self.webRtcClient?.mediaStream(withLabel: LOCAL_MEDIA_STREAM_ID)
            localMediaStream.addVideoTrack(localVideoTrack)
            localMediaStream.addAudioTrack(localAudioTrack)
            
            // local video view added stream
            localVideoTrack.add(localView)
            
            //
            //self.peerConnection?.add(localMediaStream)
        }
        
        
    }
    
    
    //MARK: WebRTC Helper
    
    
    
    func defaultStunServer() -> RTCICEServer {
        let url = URL.init(string: stunServer);
        let iceServer = RTCICEServer.init(uri: url, username: "", password: "")
        return iceServer!
    }
    
    func createAudioVideoConstraints() -> RTCMediaConstraints{
        let audioOffer : RTCPair = RTCPair(key: "OfferToReceiveAudio", value: "true")
        let videoOffer : RTCPair = RTCPair(key: "OfferToReceiveVideo", value: "true")
        let dtlsSrtpKeyAgreement : RTCPair = RTCPair(key: "DtlsSrtpKeyAgreement", value: "true")
        
        let connectConstraints : RTCMediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: [audioOffer,videoOffer], optionalConstraints: [dtlsSrtpKeyAgreement])
        
        return connectConstraints
    }
    
    func createDefaultConstraint() -> RTCMediaConstraints {
        let dtlsSrtpKeyAgreement : RTCPair = RTCPair(key: "DtlsSrtpKeyAgreement", value: "true")
        let connectConstraints : RTCMediaConstraints = RTCMediaConstraints.init(mandatoryConstraints: nil, optionalConstraints: [dtlsSrtpKeyAgreement])
        
        return connectConstraints
    }
}

extension outGoingCallPage : RTCPeerConnectionDelegate {
    
    //MARK: RTCPeerConnectionDelegate
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, signalingStateChanged stateChanged: RTCSignalingState)
    {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, addedStream stream: RTCMediaStream!) {
        if (peerConnection == nil) {
            return
        }
        if (stream.audioTracks.count > 1 || stream.videoTracks.count > 1)
        {
            //Log(value: "Weird-looking stream: " + stream.description)
            return
        }
        if (stream.videoTracks.count == 1) {
            remoteVideoTrack = stream.videoTracks[0] as! RTCVideoTrack
            remoteVideoTrack.setEnabled(true)
            remoteVideoTrack.add(remoteView);
        }
        
    }
    
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, removedStream stream: RTCMediaStream!) {
        
        remoteVideoTrack = nil
        remoteAudioTrack = nil
        
    }
    
    func peerConnection(onRenegotiationNeeded peerConnection: RTCPeerConnection!) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, iceConnectionChanged newState: RTCICEConnectionState)
    {
        if newState == RTCICEConnectionConnected
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                self.adjustFrame()
            }, completion: nil)
        }
        
    }
    func adjustFrame()
    {
        self.remoteView.isHidden = false
        self.localView.frame = CGRect (x: FULL_WIDTH-100, y: FULL_WIDTH-150, width: 80, height: 80)
        self.remoteView.frame = CGRect(x: 0, y: 0, width: FULL_WIDTH, height: FULL_HEIGHT)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, iceGatheringChanged newState: RTCICEGatheringState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, gotICECandidate candidate: RTCICECandidate!) {
        
        //to be implemented when ice candiate use case known
        
        DispatchQueue.main.async {
            if (candidate != nil)
            {
                
                let candidate = ["candidate" : candidate.sdp,
                                 "id" : candidate.sdpMid,
                                 "type" :"candidate",
                                 "label" : candidate.sdpMLineIndex] as [String : Any]
                let candidateJson = ["room" : "Dinesh",
                                     "message" : candidate ] as [String : Any]
                
                let msgDict = NSMutableDictionary()
                msgDict.addEntries(from: candidateJson)
                
                //self.socket?.write(string: candidateJson.json)
                callSocket.sharedInstance.RTCMessage(requestDict: msgDict)

    
                
            }
        }
        
        
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, didOpen dataChannel: RTCDataChannel!) {
        //        print("remote data channel name \(dataChannel.label)")
        //        dataChannel.delegate = self
        //        self.rtcDataChannelRemote = dataChannel
        
    }
}
extension outGoingCallPage : RTCSessionDescriptionDelegate {
    
    //MARK:RTCSessionDescriptionDelegate
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, didCreateSessionDescription sdp: RTCSessionDescription!, error: Error!) {
        
        if sdp.type == "offer"
        {
            
            self.peerConnection?.setLocalDescriptionWith(self, sessionDescription: sdp)
            let sdpDict : [String : String] = ["type" : sdp.type,
                                               "sdp" : sdp.description]
            
            let reqDict = NSMutableDictionary()
            reqDict.setValue("Dinesh", forKey: "room")
            reqDict.setValue(sdpDict, forKey: "message")
            callSocket.sharedInstance.RTCMessage(requestDict: reqDict)
        }
        else if sdp.type == "answer"
        {
            
            self.peerConnection?.setLocalDescriptionWith(self, sessionDescription: sdp)
            let sdpDict : [String : String] = ["type" : sdp.type,
                                               "sdp" : sdp.description]
            
            let reqDict = NSMutableDictionary()
            reqDict.setValue("Dinesh", forKey: "room")
            reqDict.setValue(sdpDict, forKey: "message")
            callSocket.sharedInstance.RTCMessage(requestDict: reqDict)
            
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection!, didSetSessionDescriptionWithError error: Error!) {
        
        if error != nil {
            
            print(error.localizedDescription)
        }
    }
    
    
}


extension outGoingCallPage : RTCEAGLVideoViewDelegate {
    
    //MARK:RTCEAGLVideoViewDelegate
    func videoView(_ videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
        
    }
    
}
