#Playcorder

Audio Player and Recorder written in ActionScript3 with JavaScript interface.

##Pros

1. Better and cleaner APIs.
2. Provides API that allow you to do a pre-connection before actual recording.
3. Make sure local buffer is properly emptied before actually closing the connection. (There was a bug in WaveRecorder that if you are in slow network you cannot send all audio content to the server when you close it.)
4. Used Deferred and Promise internally
5. Used StateMachine internally to build the robust recording functionalities.
6. No global event handler needed, no global pollution.
7. No more user privacy leak, permission will be asked again when any 3rd party malicious website try to reuse SWF.
8. Internally used Monster Debugger for easier debugging.
9. Multiple instance of playcorder is possible.

##Build

* Install Nodejs
* Install dependencies

        npm install

* Run Grunt

        grunt
   
##Debug

To see logs from Playcorder, install MonsterDebugger <http://www.monsterdebugger.com>

##API

###Playcorder

####Methods

1. getID - get the instance ID of current playcorder

####Events

1. onready - fire when playcorder is ready


###Player

####Methods

0. player.initialize() - init the player.
1. player.start(pathToMedia:String) - start playing the specified file.
2. player.stop() - stop the playback

####Events

1. player.onstarted - fired when playback started
2. player.onstoppped - fire when playback stoppped

###Recorder

####Config

    {
        gain:50, 
        rate:44, 
        silence:0, 
        quality: 9,
        type:'asrrtmp', // recorder type, can be 'local', 'rtmp', 'asrrtmp'
        server: 'rtmpt://speechtest.englishtown.com:1935/asrstreaming', // server addr if rtmp recorder is choosen
        ids: {
            student:23653966, // student id
            activity:321 // activity id
        }
    }
    
####Methods

0. recorder.initialize(config) - init recorder with specified config.
1. recorder.start()
2. recorder.stop()
3. recorder.activity() - return 0 - 100, indicates microphone volumn.
4. recorder.muted() - return true indicates that the microphone is muted
5. recorder.connect() - do the pre-connection (if appilcable), currently only works on ef rtmpt protocol (if you are on rtmp, server will disconnect it when it is idle more than 3 sec).
6. recorder.disconnect() - disconnect (if applicable)
7. recorder.result.type() - get type of result
8. recorder.result.duration() - get duration of the result
9. recorder.result.download(type) - download result as specified type, could be 'raw' or 'wave'
10. recorder.result.upload(type, url) - upload result to remote url

####Events

1. recorder.onconnected
2. recorder.ondisconnected
3. recorder.onstarted
4. recorder.onstopped
5. recorder.onchange -  possible event code are:

    * microphone.not_found - trigger when microphone is unplugged
    * microphone.found - trigger when microphone is plugged
    * microphone.muted - trigger when microphone is muted
    * microphone.unmuted - trigger when microphone is unmuted
    
6. recorder.onerror - possible event code are:
    * connection.fail - fire when the connection failed.

##TODO

1. Encoding in worker
2. Download or upload progress report
3. Progressively upload (using multipart)
4. Encode in mp3
5. Encode in speex or opus
6. Remove ASRRTMPRecorder.as make playcorder more generic
