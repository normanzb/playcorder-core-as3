package players
{
    import flash.media.Sound;
    import flash.events.SampleDataEvent;
    import flash.utils.ByteArray;

    import Playcorder;
    import tickets.Ticket;
    import helpers.Constants;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.demonsters.debugger.MonsterDebugger;

    public class LocalPlayer extends Player
    {
        // according to 
        // http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/SampleDataEvent.html
        private const COUNT_SAMPLE_MIN:uint = 2048;
        private const COUNT_SAMPLE_MAX:uint = 8192;

        private var _raw:ByteArray;
        private var _rate:int = 0;
        private var _output:Sound = new Sound();
        private var _dfdPlaying:Deferred;

        function LocalPlayer(cfg:Object)
        {
            super(cfg);

            _output.addEventListener( SampleDataEvent.SAMPLE_DATA, handleSoundSample );
        }

        private function handleSoundSample(evt:SampleDataEvent):void
        {
            if ( _dfdPlaying == null )
            {
                return;
            }

            var count:int = 0;
            var sample:Number = 0;

            while ( _raw.bytesAvailable && count < COUNT_SAMPLE_MAX )
            {
                sample = _raw.readFloat();
                // write sample twice because of 2 channels by default
                evt.data.writeFloat( sample );
                evt.data.writeFloat( sample );
                count+=2;
            }

        }

        private function playSound():void
        {
            if ( _raw == null || _rate == 0)
            {
                MonsterDebugger.trace(this, 'try to play sound but not data' );

                return;
            }

            _dfdPlaying = new Deferred();
            _raw.position = 0;
            
            _output.play();

            MonsterDebugger.trace(this, 'sound outputing started' );
        }

        private function stopSound():void
        {
            _dfdPlaying.resolve( null );

            _dfdPlaying = null;
        }

        public override function play(source:*):Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:Ticket = new Ticket(dfd.promise);

            start( source );

            dfd.resolve( _dfdPlaying.promise );

            return ret;
        }

        // currently only accept raw bytearray
        // TODO(?): 
        //      add mp3 bytearray: https://gist.github.com/claus/218226
        //      or leaving such thing to soundmanager is a better idea?
        public override function start(source:*):Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:Ticket = new Ticket(dfd.promise);

            var dfdExtract:Deferred = new Deferred();

            if ( source == null ) 
            {
                // get source from last recorded audio
                if ( 
                    Playcorder.inst == null || 
                    Playcorder.inst.recorder == null || 
                    Playcorder.inst.recorder.result == null 
                )
                {
                    throw new Error("This method can only be called either when source is specified or has recorded.")
                }

                var ticketExtract:Ticket = Playcorder.inst.recorder.result.download('raw');
                dfdExtract.resolve( ticketExtract.promise );
            }
            else
            {
                if ( typeof source['format'] != 'string' )
                {
                    source['format'] = 'PCM-32BIT-Float';
                }

                dfdExtract.resolve( source );
            }

            dfdExtract
                .promise
                .then(
                    function(obj:Object):void
                    {
                        _raw = obj.data as ByteArray;
                        _rate = obj.rate as int;
                        playSound();

                        dfd.resolve( null );
                    }, 
                    dfd.reject
                );

            return ret;
        }

        public override function stop():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:Ticket = new Ticket(dfd.promise);

            stopSound();

            dfd.resolve( null );

            return ret;
        }

        public override function dispose():void
        {
            stop();
            _raw = null;
        }
    }
}