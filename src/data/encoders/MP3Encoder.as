package data.encoders
{
    import flash.system.Worker;
    import flash.utils.ByteArray;
    import im.norm.data.encoders.MP3Encoder;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    import Playcorder;

    public class MP3Encoder
        extends Encoder
    {
        public function MP3Encoder()
        {
            workerBytes = Playcorder.inst.loaderInfo.bytes;
            targetFormat = 'mp3';
        }
        public override function encode( ba:ByteArray, config:Object ):Promise
        {
            var dfd:Deferred = new Deferred();

            if ( !Worker.isSupported )
            {
                MonsterDebugger.trace( this, 'worker is NOT supported' );

                var mp3e:im.norm.data.encoders.MP3Encoder = new im.norm.data.encoders.MP3Encoder;
                var mp3ByteArray:ByteArray = mp3e.encode.apply( mp3e, arguments );

                dfd.resolve( mp3ByteArray );
            }
            else
            {
                MonsterDebugger.trace( this, 'worker is supported' );

                dfd.resolve(super.encode.apply(this, arguments));
            }

            return dfd.promise;
        }
    }
}