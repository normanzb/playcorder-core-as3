package workers.encoders
{
    import flash.display.Sprite;
    import flash.net.registerClassAlias;
    import flash.system.MessageChannel;
    import flash.system.Worker;
    import flash.events.Event;
    import flash.utils.ByteArray;

    import workers.messages.Message;

    import com.demonsters.debugger.MonsterDebugger;

    public class Base
        extends Sprite
    {
        public static var CHANNEL_IN:String = 'channel.in';
        public static var CHANNEL_OUT:String = 'channel.out';
        public static var INTERNAL_ENCODER:String = 'internal.encoder';

        protected var inputChannel:MessageChannel;
        protected var outputChannel:MessageChannel;

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

        protected function handleEncode(...args):void
        {
            throw new Error("Not implemented");
        }

        public function Base()
        {
            // register the Class so that we can use it to pass between workers
            registerClassAlias("workers.messages.Message", Message);

            inputChannel = Worker.current.getSharedProperty(Base.CHANNEL_IN) as MessageChannel;
            outputChannel = Worker.current.getSharedProperty(Base.CHANNEL_OUT) as MessageChannel;

            inputChannel.addEventListener(Event.CHANNEL_MESSAGE, handleInput);
        }
    }
}