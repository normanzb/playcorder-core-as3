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

##Build

* Install Nodejs
* Install dependencies

        npm install

* Run Grunt

        grunt
   
##Debug

To see logs from audio-helper, install MonsterDebugger <http://www.monsterdebugger.com>
