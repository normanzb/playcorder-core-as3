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
        private const DEFAULT_FREQ:int = 44;
        private const DEFAULT_NUMBER_OF_CHANNELS:int = 2;

        private var _raw:ByteArray;
        private var _rate:int = 0;
        private var _length:int = 0;
        private var _numberOfChannels:int = 1;
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
                evt.data.writeFloat( sample );
                count++;
            }

        }

        // TODO:
        // http://en.wikipedia.org/wiki/Downmixing
        private function downChannelMixing():void
        {
            throw new Error('Down mixing is not implemented yet, LocalPlayer currently support channels <= 2');
        }

        private function upChannelMixing():void
        {
            var data:ByteArray = new ByteArray();
            var currentChannelIndex:int = 0;
            var targetChannelIndex:int = 0;
            var channels:Array;

            _raw.position = 0;

            while( _raw.bytesAvailable )
            {
                channels = [];

                // read channel data
                for
                (
                    currentChannelIndex = 0; 
                    currentChannelIndex < _numberOfChannels && _raw.bytesAvailable > 0; 
                    currentChannelIndex++
                )
                {
                    channels.push(_raw.readFloat());
                }

                if ( channels.length != _numberOfChannels )
                {
                    // channel info not intact, don't play it
                    break;
                }

                for
                ( 
                    targetChannelIndex = 0; 
                    targetChannelIndex < DEFAULT_NUMBER_OF_CHANNELS; 
                    targetChannelIndex++
                )
                {
                    data.writeFloat( channels[targetChannelIndex % _numberOfChannels] );
                }
            }

            _numberOfChannels = DEFAULT_NUMBER_OF_CHANNELS;
            _raw = data;
        }

        private function upSampling():void
        {
            var data:ByteArray = new ByteArray();
            var currentSampleIndex:int = 0;
            var targetSampleIndex:int = 0;
            var samples:Array;
            var precisionRate:int = Constants.sampleRates[_rate];

            _raw.position = 0;

            while( _raw.bytesAvailable )
            {
                samples = [];

                // read channel data
                for
                (
                    currentSampleIndex = 0; 
                    currentSampleIndex < precisionRate && _raw.bytesAvailable > 0; 
                    currentSampleIndex++
                )
                {
                    samples.push(_raw.readFloat());
                }

                if ( samples.length != precisionRate )
                {
                    // samples info not intact, don't play it
                    break;
                }

                for
                ( 
                    targetSampleIndex = 0; 
                    targetSampleIndex < Constants.sampleRates[DEFAULT_FREQ]; 
                    targetSampleIndex++
                )
                {
                    currentSampleIndex = ( precisionRate * targetSampleIndex / Constants.sampleRates[DEFAULT_FREQ] ) >>> 0 ;
                    data.writeFloat( samples[ currentSampleIndex ] );
                }
            }

            _rate = DEFAULT_FREQ;
            _raw = data;
        }

        private function downSampling():void
        {
            throw new Error('Down sampling is not implemented yet, LocalPlayer currently support rate <= 44');
        }

        private function playSound():void
        {
            if ( _raw == null || _rate == 0)
            {
                MonsterDebugger.trace(this, 'try to play sound but not data' );

                return;
            }

            _dfdPlaying = new Deferred();

            if ( _numberOfChannels > DEFAULT_NUMBER_OF_CHANNELS )
            {
                MonsterDebugger.trace(this, 'down mixing...' );
                downChannelMixing();
                MonsterDebugger.trace(this, 'down mixing is done' );
            }
            else ( _numberOfChannels < DEFAULT_NUMBER_OF_CHANNELS )
            {
                MonsterDebugger.trace(this, 'up mixing...' );
                upChannelMixing();
                MonsterDebugger.trace(this, 'up mixing is done' );
            }

            if ( _rate * _numberOfChannels < DEFAULT_FREQ * DEFAULT_NUMBER_OF_CHANNELS )
            {
                MonsterDebugger.trace(this, 'up sampling...' );
                upSampling();
                MonsterDebugger.trace(this, 'up sampling is done' );
            }
            else if ( _rate * _numberOfChannels > DEFAULT_FREQ * DEFAULT_NUMBER_OF_CHANNELS )
            {
                MonsterDebugger.trace(this, 'down sampling...' );
                downSampling();
                MonsterDebugger.trace(this, 'down sampling is done' );
            }

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
                else 
                {
                    if ( source['format'] != 'PCM-32BIT-Float')
                    {
                        // TODO: convert?
                        dfdExtract.reject
                        (
                            'Currently only support 32bit float PCM, ' + source['format'] + ' is not supported'
                        );
                    }
                }

                dfdExtract.resolve( source );
            }

            dfdExtract
                .promise
                .then(
                    function(obj:Object):void
                    {
                        var channels:Array = (obj['channels'] as Array);
                        _raw = obj.data as ByteArray;
                        _rate = obj.rate as int;
                        _length = obj.length as int;
                        _numberOfChannels = channels ? channels.length : 1;

                        try
                        {
                            playSound();
                        }
                        catch(ex:*)
                        {
                            dfd.reject(ex);
                        }

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