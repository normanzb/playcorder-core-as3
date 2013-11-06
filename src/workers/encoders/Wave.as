package workers.encoders
{
    import flash.utils.ByteArray;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.registerClassAlias;
    import flash.system.MessageChannel;
    import flash.system.Worker;

    import workers.messages.Message;
    import im.norm.data.encoders.WaveEncoder;

    import com.demonsters.debugger.MonsterDebugger;

    public class Wave
        extends Base
    {
        protected override function handleEncode(...args):void
        {
            var encoder:WaveEncoder = new WaveEncoder();
            var bytes:ByteArray;
            var prg:Message = new Message();
            var result:Message = new Message();

            prg.type = 'progress';
            prg.value = 0;

            // send progress 0% as start signal
            outputChannel.send( prg );

            bytes = encoder.encode.apply(encoder, args);

            prg.value = 100;

            // send progress 100% as end signal
            outputChannel.send( prg );

            result.type = 'result';
            result.value = bytes;

            // send encoded result
            outputChannel.send( result );
        }

        public function Wave()
        {
            
        }
    }
}