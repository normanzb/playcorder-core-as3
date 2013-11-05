package data.containers
{
    import flash.utils.ByteArray;
    import flash.media.Microphone;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.system.Worker;

    import tickets.GUIDTicket;
    import tickets.Ticket;
    import data.encoders.WaveEncoder;
    import im.norm.data.encoders.WaveEncoder;
    import events.EncoderEvent;
    import workers.messages.Message;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;
    import com.demonsters.debugger.MonsterDebugger;

    public class RAWAudioContainer
        extends Container
    {
        private var _mic:Microphone;
        private static var sampleRates:Object = {
            44: 44100,
            22: 22050,
            11: 11025,
            8: 8000,
            5: 5512
        };

        function RAWAudioContainer(mic:Microphone)
        {
            _type = 'raw-audio';
            _mic = mic;
        }

        public override function download(type:String):Ticket
        {
            var me:Container = this;
            var dfd:Deferred = new Deferred();
            var ticket:GUIDTicket = new GUIDTicket(dfd.promise);

            if ( type == null ) 
            {
                // default to use byte array rather than binary string is because
                // there is a bug in externalinterface.call that prevents String.fromCharCode(0x0) to be passed.
                type = "raw";
            }

            MonsterDebugger.trace( me, 'try to download data: ' + type );

            nextTick(function():void
            {
                var dfdEncoding:Deferred = new Deferred();

                if ( data is ByteArray )
                {
                    MonsterDebugger.trace( me, 'data is byte array');

                    var ba:ByteArray = ByteArray(data);
                    var outputArray:Array = new Array();

                    if ( type == "raw" )
                    {
                        try
                        {
                            ba.position = 0;

                            while( ba.bytesAvailable > 0 )
                            {
                                outputArray.push( ba.readUnsignedByte() );
                            }
                            
                            MonsterDebugger.trace( me, 'got result' );

                            dfdEncoding.resolve(outputArray);
                        }
                        catch ( ex:Error )
                        {
                            MonsterDebugger.trace( me, 'fail to get result: ' + ex.toString() );

                            dfdEncoding.reject( ex.toString() );

                            return;
                        }
                    }
                    else if ( type == "wave" )
                    {
                        if ( Worker.isSupported )
                        {
                            MonsterDebugger.trace( me, 'worker is supported' );

                            var weAsync:data.encoders.WaveEncoder = new data.encoders.WaveEncoder();

                            weAsync
                                .encode( ba, {
                                    rate: sampleRates[ _mic.rate ],
                                    numberOfChannels: 1
                                })
                                .then(
                                    function(result:*):void
                                    {
                                        MonsterDebugger.trace( me, 'async wave encoding finished' );

                                        if ( !(result is ByteArray) )
                                        {
                                            dfdEncoding.reject('result is not ByteArray');
                                            return;
                                        }

                                        var waveByteArray:ByteArray = result as ByteArray;

                                        waveByteArray.position = 0;

                                        while( waveByteArray.bytesAvailable > 0 )
                                        {
                                            outputArray.push( waveByteArray.readUnsignedByte() );
                                        }

                                        dfdEncoding.resolve( outputArray );
                                    });
                        }
                        else
                        {
                            MonsterDebugger.trace( me, 'worker is not supported' );

                            var we:im.norm.data.encoders.WaveEncoder = new im.norm.data.encoders.WaveEncoder();
                            var waveByteArray:ByteArray = we.encode( ba, 
                            {
                                rate: sampleRates[ _mic.rate ],
                                numberOfChannels: 1
                            } );
    
                            waveByteArray.position = 0;
    
                            while( waveByteArray.bytesAvailable > 0 )
                            {
                                outputArray.push( waveByteArray.readUnsignedByte() );
                            }
     
                            dfdEncoding.resolve( outputArray );
                        }
                            
                    }
                    else
                    {
                        dfdEncoding.reject("download type is not supported");
                        return;
                    }

                    dfdEncoding
                        .promise
                        .then(
                            function(result:*):void
                            {
                                dfd.resolve( 
                                {
                                    guid: ticket.guid,
                                    data: result,
                                    length: ba.length,
                                    rate: _mic.rate,
                                    // always 1 input source from flash:
                                    // http://stackoverflow.com/questions/9380499/recording-audio-works-playback-way-too-fast
                                    channels: [true]
                                });
                            }, 
                            dfd.reject
                        );
                }
                else 
                {
                    dfd.reject("data format is not supported");
                }
            });

            return ticket;
        }

        public override function upload(type:String, url:String):Ticket
        {
            var me:Container = this;
            var dfd:Deferred = new Deferred();
            var ticket:GUIDTicket = new GUIDTicket(dfd.promise);

            var tcktDownload:Ticket = download( type );

            tcktDownload
                .promise
                .then(
                    function(obj:Object):void
                    {
                        // try uploading
                        var request:URLRequest = new URLRequest(url);
                        var loader:URLLoader = new URLLoader();

                        request.method = URLRequestMethod.POST;
                        request.data = obj.data;

                        loader.addEventListener(
                            Event.COMPLETE, 
                            function(evt:Event):void
                            {
                                dfd.resolve( null );
                            });

                        
                        loader.addEventListener(IOErrorEvent.IO_ERROR, 
                            function(evt:IOErrorEvent):void
                            {
                                dfd.reject('fail to upload, ex: ' + evt.toString())
                            });

                        loader.load(request);
                    },
                    dfd.reject
                );
            
            return ticket;   
        }

        /*
         * Return the length of the audio (in seconds)
         */
        public function get duration():int
        {
            var ret:int = 0;

            if ( data is ByteArray )
            {
                var ba:ByteArray = ByteArray(data);

                // each sample is a 32bit float == 4 bytes
                ret = ba.length / ( sampleRates[ _mic.rate ] * 4 );
            }

            return ret;
        }
    }
}