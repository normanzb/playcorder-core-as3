package data.encoders
{
    import flash.utils.ByteArray;
    import flash.system.MessageChannel;
    import flash.system.Worker;
    import flash.system.WorkerDomain;
    import flash.system.WorkerState;
    import flash.net.registerClassAlias;
    import flash.events.Event;

    import events.EncoderEvent;
    import workers.messages.Message;
    import workers.encoders.Base;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;

    public class Encoder
    {
        protected var workerBytes:ByteArray;
        protected var backgroundWorker:Worker;
        protected var encodingPromise:Promise;
        protected var targetFormat:String;

        public function Encoder()
        {
            registerClassAlias("workers.messages.Message", Message);
        }

        public function encode( ba:ByteArray, config:Object ):Promise
        {
            var dfd:Deferred;
            var me:Encoder = this;
            var args:Object = arguments;
            var inputChn:MessageChannel;
            var outputChn:MessageChannel;

            var funcCleanUp:Function = function(obj:*):*
                {
                    // clean up
                    backgroundWorker = null;
                    encodingPromise = null;

                    return obj;
                };

            var funcRecursion:Function = function():Promise
                {
                    return encode.apply(me, args);
                };

            if ( backgroundWorker != null && encodingPromise != null )
            {
                return encodingPromise
                    .then(funcRecursion, funcRecursion);
            }

            dfd = new Deferred();

            encodingPromise = dfd.promise.then(funcCleanUp, funcCleanUp);

            backgroundWorker = WorkerDomain.current.createWorker(workerBytes);

            backgroundWorker.setSharedProperty('target.format', targetFormat);

            inputChn = Worker.current.createMessageChannel(backgroundWorker);
            backgroundWorker.setSharedProperty(Base.CHANNEL_IN, inputChn);

            outputChn = backgroundWorker.createMessageChannel(Worker.current);
            backgroundWorker.setSharedProperty(Base.CHANNEL_OUT, outputChn);

            outputChn.addEventListener(Event.CHANNEL_MESSAGE, 
                function handleOutputMessage(evt:Event):void
                {
                    if ( !outputChn.messageAvailable )
                    {
                        return;
                    }

                    var msg:Message = outputChn.receive() as Message;
                    
                    if ( msg.type == 'result' )
                    {
                        MonsterDebugger.trace( me, 'encoding is done' );

                        var result:ByteArray = msg.value as ByteArray;

                        if ( result == null )
                        {
                            dfd.reject( 'unknown reason' );
                        }

                        dfd.resolve( result );
                    }
                    else if ( msg.type == 'progress' )
                    {
                        MonsterDebugger.trace( me, 'progressed to ' + msg.value );
                    }
                });

            // Start the worker
            backgroundWorker.addEventListener(Event.WORKER_STATE, function handleWorkerStateChange(evt:Event):void
            {
                if ( backgroundWorker.state == WorkerState.RUNNING )
                {
                    var msgEncode:Message = new Message();
                    msgEncode.type = 'encode';
                    msgEncode.value = [ ba, config ];

                    MonsterDebugger.trace( me, 'send message to start encoding' );
                    inputChn.send(msgEncode)
                }
            });

            MonsterDebugger.trace( me, 'kick off worker' );
            backgroundWorker.start();

            return encodingPromise;
        }
    }
}