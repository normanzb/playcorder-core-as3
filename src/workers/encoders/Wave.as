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
        extends Sprite
    {
        public static var CHANNEL_IN:String = 'channel.in';
        public static var CHANNEL_OUT:String = 'channel.out';
        private var inputChannel:MessageChannel;
        private var outputChannel:MessageChannel;

        private function handleInput(event:Event):void
        {
            var message:Message;

            if ( !inputChannel.messageAvailable )
            {
                return;
            }

            message = inputChannel.receive() as Message;

            if ( message == null )
            {
                return;
            }

            if ( message.type == 'encode' && message.value is Array )
            {
                MonsterDebugger.trace( this, 'start encoding' );

                handleEncode.apply(this, message.value as Array);
            }
        }

        private function handleEncode(...args):void
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
            // register the Class so that we can use it to pass between workers
            registerClassAlias("workers.messages.Message", Message);

            inputChannel = Worker.current.getSharedProperty(CHANNEL_IN) as MessageChannel;
            outputChannel = Worker.current.getSharedProperty(CHANNEL_OUT) as MessageChannel;

            inputChannel.addEventListener(Event.CHANNEL_MESSAGE, handleInput);
        }
    }
}