#Playcorder.Core.AS3

Audio Player and Recorder written in ActionScript3 with JavaScript interface.

##Pros

1. Cleaner APIs, no global event handler needed, no global pollution.
2. When doing realtime recording (RTMP), playcorder allows you to do a pre-connection before actual recording.
3. SWF file can be hosted on CDN server.
4. No privacy leaking when swf is hosted on CDN, microphone permission will be prompted again when page domain name changed. (This prevent any 3rd party to reuse the hosted SWF and hence gaining the microphone access permission WITHOUT actual user approval.)
5. Multiple instance of playcorder is possible.
6. Internally used Monster Debugger for easier debugging.
7. Non-blocking encoding.
8. Extracting raw, wave and mp3 data.

##Versions

###Player Version

11.9

###mxmlc Version

4.10.0

##Download

<https://github.com/normanzb/playcorder-core-as3/blob/master/dist/Playcorder.swf?raw=true>

##Build

* Install Nodejs
* Install Flex SDK, make sure mxmlc can be found in your $PATH.
* Install dependencies

        npm install

* Clone all submodules

        git submodule update --init --recursive

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
9. recorder.result.download(type) - download result as specified type, could be 'raw' or 'wave' or 'mp3'
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

see <https://github.com/normanzb/playcorder-core-as3/issues?labels=todo&page=1&state=open>

##Contribute

You can contribute the project by:

* Submitting pull request
* Git tipping me: <https://www.gittip.com/normanzb/>

##Acknowledge

This library internally used or is using below 3rd party libraries, playcorder cannot work as what we have nowaday without the efforts from the authors.

Shine MP3 Encoder:  Gabriel Bouvigne <http://gabriel.mp3-tech.org/>

Shine MP3 Encoder Alchemy: kikko <https://github.com/sri-soham/Shine-MP3-Encoder-on-AS3-Alchemy>
