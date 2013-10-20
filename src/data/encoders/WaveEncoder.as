package data.encoders
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import com.demonsters.debugger.MonsterDebugger;

    public class WaveEncoder
        extends Encoder
    {
        private const ID_CHUNK:String = 'RIFF';
        private const ID_CHUNK_SUB_FORMAT:String = 'fmt ';
        private const ID_CHUNK_SUB_DATA:String = 'data';
        private const TYPE_RIFF_WAVE:String = 'WAVE';
        private const BIT_LEN:int = 16;
        private const BYTE_PER_SAMPLE:Number = BIT_LEN / 8;
        private const RATES:Array = [ 
            5512,
            // walkie-talkie
            8000, 
            // lower quality PCM, 1/4 CD
            11025,
            // wideband, telephone, voip
            16000,
            // half sampling rate of audio CD
            22050,
            // miniDV camcorder
            32000,
            // NTSC
            44056,
            // main stream, audio CD, MPEG-1, VCD, SVCD, MP3
            44100,
            // NIPPON COLUMBIA
            47250,
            // professional digital video equipment
            48000,
            // DVD-audio
            96000
        ];

        private function floatTo16BitPC( ba:ByteArray, samples:Vector.<Number> ):void
        {
            for( var i:int = 0; i < samples.length; i++ )
            {
                var s:Number = Math.max( -1, Math.min( 1, samples[i] ) );
                ba.writeShort( s < 0 ? s * 0x8000 : s * 0x7FFF );
            }
        }

        function WaveEncoder()
        {

        }

        public override function encode(ba:ByteArray, config:Object ):ByteArray
        {
            var ret:ByteArray;
            var samples:Vector.<Number>;
            var cur:int = 0;

            var rate:Number = config['rate'];
            var numberOfChannels:Number = config['numberOfChannels'];

            if ( ba == null )
            {
                throw "byte array required";
            }

            if ( RATES.indexOf( rate ) < 0 )
            {
                throw "Sample rate is not expected";
            }

            if ( numberOfChannels < 1 )
            {
                throw "Incorrect number of channels";
            }

            // get the samples out of byte array
            samples = new Vector.<Number>;

            //ba.endian = Endian.LITTLE_ENDIAN;
            ba.position = 0;
            while( ba.bytesAvailable > 0 )
            {
                samples.push( ba.readFloat() );
            }
            MonsterDebugger.trace( this, 'samples are extracted' );

            // build wave file
            // https://ccrma.stanford.edu/courses/422/projects/WaveFormat/
            ret = new ByteArray()

            ret.endian = Endian.LITTLE_ENDIAN;

            // RIFF ID
            ret.writeUTFBytes( ID_CHUNK );

            // file length
            ret.writeUnsignedInt( 36 + samples.length * BYTE_PER_SAMPLE );

            // RIFF type
            ret.writeUTFBytes( TYPE_RIFF_WAVE );

            // format chunk: ID
            ret.writeUTFBytes( ID_CHUNK_SUB_FORMAT );

            // format chunk: length
            ret.writeUnsignedInt( 16 );

            // sample format: raw
            ret.writeShort( 1 );

            // number of channels
            ret.writeShort( numberOfChannels );

            // sample rate
            ret.writeUnsignedInt( rate );

            // byte rate ( sample rate * block align )
            ret.writeUnsignedInt( rate * BYTE_PER_SAMPLE * numberOfChannels );

            // block align ( channel count * bytes per sample )
            ret.writeShort( numberOfChannels * BYTE_PER_SAMPLE );

            // bits per sample
            ret.writeShort( BIT_LEN );

            // data chunk: ID
            ret.writeUTFBytes( ID_CHUNK_SUB_DATA );

            // data chunk: length
            ret.writeUnsignedInt( samples.length * BYTE_PER_SAMPLE );

            floatTo16BitPC( ret, samples );

            MonsterDebugger.trace( this, 'wave encoded' );

            return ret;
        }
    }
}