package data.encoders
{
    import flash.system.Worker;
    import flash.utils.ByteArray;
    import im.norm.data.encoders.WaveEncoder;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    public class WaveEncoder
        extends Encoder
    {
        public function WaveEncoder()
        {
            workerBytes = Playcorder.inst.loaderInfo.bytes;
            targetFormat = 'wave';
        }

        public override function encode( ba:ByteArray, config:Object ):Promise
        {
            var dfd:Deferred = new Deferred();

            if ( Worker.isSupported )
            {
                MonsterDebugger.trace( this, 'worker is supported' );

                dfd.resolve(super.encode.apply(this, arguments));
            }
            else
            {
                MonsterDebugger.trace( this, 'worker is NOT supported' );

                var we:im.norm.data.encoders.WaveEncoder = new im.norm.data.encoders.WaveEncoder();
                var waveByteArray:ByteArray = we.encode.apply( we, arguments )

                dfd.resolve( waveByteArray );
            }

            return dfd.promise;
        }
    }
}