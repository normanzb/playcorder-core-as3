package workers.encoders
{
    import flash.utils.ByteArray;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.registerClassAlias;
    import flash.system.MessageChannel;
    import flash.system.Worker;

    import workers.messages.Message;

    import im.norm.data.encoders.MP3Encoder;
    import com.demonsters.debugger.MonsterDebugger;

    public class MP3
        extends Base
    {
        protected override function handleEncode(...args):void
        {
            var me:Base = this;

            var mp3Encoder:MP3Encoder = new MP3Encoder();
            var bytes:ByteArray;
            var prg:Message = new Message();
            
            prg.type = 'progress';
            prg.value = 0;

            // send progress 0% as start signal
            outputChannel.send( prg );

            MonsterDebugger.trace( me, 'encoding to mp3...' );

            bytes = mp3Encoder.encode.apply(mp3Encoder, args);

            MonsterDebugger.trace( me, 'encoding mp3: completed' );

            prg.value = 100;

            // send progress 100% as end signal of encoding mp3
            outputChannel.send( prg );

            MonsterDebugger.trace( me, 'try to send the encoding result data' );

            var result:Message = new Message();
            result.type = 'result';
            result.value = bytes;

            // send encoded result
            outputChannel.send( result );
        }
    }
}