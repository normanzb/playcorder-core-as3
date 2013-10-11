#Audio-Helper

Audio Player and Recorder written in ActionScript3 with JavaScript interface.

##Pros

1. Better and cleaner APIs.
2. Provides API that allow you to do a pre-connection before actual recording.
3. Make sure local buffer is properly emptied before actually closing the connection. (There was a bug in WaveRecorder that if you are in slow network you cannot send all audio content to the server when you close it.)
4. Used Deferred and Promise internally
5. Used StateMachine internally to build the robust recording functionalities.
6. No global event handler needed, no global pollution.
7. Only user that in EF domains are allow to interact with the JavaScript API. This guarantined the safety of our users' privacy.
8. Internally used Monster Debugger for easier debugging.

##Build

* Install Nodejs
* Install dependencies

        npm install

* Run Grunt

        grunt
   
##Debug

To see logs from audio-helper, install MonsterDebugger <http://www.monsterdebugger.com>

##API

###Player

####Methods

0. player_initialize() - init the player.
1. player_start(pathToMedia:String) - start playing the specified file.
2. player_stop() - stop the playback

####Events

1. player_onstarted - fired when playback started
2. player_onstoppped - fire when playback stoppped

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

0. recorder_initialize(config) - init recorder with specified config.
1. recorder_start()
2. recorder_stop()
3. recorder_activity() - return 0 - 100, indicates microphone volumn.
4. recorder_muted() - return true indicates that the microphone is muted
5. recorder_connect() - do the pre-connection (if appilcable), currently only works on ef rtmpt protocol (if you are on rtmp, server will disconnect it when it is idle more than 3 sec).
6. recorder_disconnect() - disconnect (if applicable)

####Events

1. onready - fire when playcorder is ready
2. recorder_onconnected
2. recorder_ondisconnected
3. recorder_onstarted
4. recorder_onstopped
5. recorder_onchange -  possible event code are:

    * microphone.not_found - trigger when microphone is unplugged
    * microphone.found - trigger when microphone is plugged
    * microphone.muted - trigger when microphone is muted
    * microphone.unmuted - trigger when microphone is unmuted
    
6. recorder_onerror - possible event code are:
    * connection.fail - fire when the connection failed.