package data.containers
{
    import flash.utils.ByteArray;
    import flash.media.Microphone;

    import tickets.GUIDTicket;
    import tickets.Ticket;
    import data.encoders.WaveEncoder;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;
    import com.demonsters.debugger.MonsterDebugger;

    public class RAWAudioContainer
        extends Container
    {
        private var _mic:Microphone;

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
                var result:*;

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

                            result = outputArray;
                            
                            MonsterDebugger.trace( me, 'got result' );
                        }
                        catch ( ex:Error )
                        {
                            MonsterDebugger.trace( me, 'fail to get result: ' + ex.toString() );

                            dfd.reject( ex.toString() );

                            return;
                        }
                    }
                    else if ( type == "wave-file" )
                    {
                        var we:WaveEncoder = new WaveEncoder();
                        var sampleRates:Object = {
                            44: 44100,
                            22: 22050,
                            11: 11025,
                            8: 8000,
                            5: 5512
                        };
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

                        result = outputArray;
                    }
                    else
                    {
                        dfd.reject("download type is not supported");
                        return;
                    }

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

                }
                else 
                {
                    dfd.reject("data format is not supported");
                }
            });


            return ticket;
        }
    }
}