#Playcorder

Audio Player and Recorder written in ActionScript3 with JavaScript interface.

##Pros

1. Cleaner APIs, no global event handler needed, no global pollution.
2. When doing realtime recording (RTMP), playcorder allows you to do a pre-connection before actual recording.
3. SWF file can be hosted on CDN server.
4. No privacy leaking when swf is hosted on CDN, microphone permission will be prompted again when page domain name changed. (This prevent any 3rd party to reuse the hosted SWF and hence gaining the microphone access permission WITHOUT actual user approval.)
5. Multiple instance of playcorder is possible.
6. Internally used Monster Debugger for easier debugging.

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
        type:'local', // recorder type, can be 'local', 'rtmp'
        server: 'rtmpt://speechtest.englishtown.com:1935/asrstreaming', // server addr if rtmp recorder is choosen
    }
    
####Methods

0. recorder.initialize(config) - init recorder with specified config.
1. recorder.start()
2. recorder.stop()
3. recorder.activity() - return 0 - 100, indicates microphone volumn.
4. recorder.muted() - return true indicates that the microphone is muted
5. recorder.connect(...args) - do the pre-connection (if appilcable), currently only works on rtmpt protocol (if you are on rtmp, server may disconnect it quickly when timeout). 'args' will be passed as is to corresponding internal connect method. For example, if it is rtmp recorder, args will be passed to NetConnection.connect();
6. recorder.disconnect() - disconnect (if applicable)
7. recorder.result.type() - get type of result
8. recorder.result.duration() - get duration of the result
9. recorder.result.download(type) - download result as specified type, could be 'raw' or 'wave'
10. recorder.result.upload(type, url) - upload result to remote url (using POST)

####Events

1. recorder.onconnected - (only available when it is RTMP recorder)
2. recorder.ondisconnected - (only available when it is RTMP recorder)
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
6. Javascript wrapper and Javascript couterpart
