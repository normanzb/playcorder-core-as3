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
    import workers.encoders.Wave;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;

    public class WaveEncoder
        extends Encoder
    {
        // ------- Embed the background worker swf as a ByteArray -------
        [Embed(source="/Worker.Encoder.Wave.swf", mimeType="application/octet-stream")]
        private static var bytClsWorker:Class;

        private var workerBackground:Worker;
        private var prmEncoding:Promise;

        function WaveEncoder()
        {
            registerClassAlias("workers.messages.Message", Message);
        }

        public override function encode( ba:ByteArray, config:Object ):Promise
        {
            var dfd:Deferred;
            var me:WaveEncoder = this;
            var args:Object = arguments;
            var inputChn:MessageChannel;
            var outputChn:MessageChannel;

            var funcCleanUp:Function = function(obj:*):*
                {
                    // clean up
                    workerBackground = null;
                    prmEncoding = null;

                    return obj;
                };

            var funcRecursion:Function = function():Promise
                {
                    return encode.apply(me, args);
                };

            if ( workerBackground != null && prmEncoding != null )
            {
                return prmEncoding
                    .then(funcRecursion, funcRecursion);
            }

            dfd = new Deferred();

            prmEncoding = dfd.promise.then(funcCleanUp, funcCleanUp);

            workerBackground = WorkerDomain.current.createWorker(new bytClsWorker);

            inputChn = Worker.current.createMessageChannel(workerBackground);
            workerBackground.setSharedProperty(Wave.CHANNEL_IN, inputChn);

            outputChn = workerBackground.createMessageChannel(Worker.current);
            workerBackground.setSharedProperty(Wave.CHANNEL_OUT, outputChn);

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
                });

            // Start the worker
            workerBackground.addEventListener(Event.WORKER_STATE, function handleWorkerStateChange(evt:Event):void
            {
                if ( workerBackground.state == WorkerState.RUNNING )
                {
                    var msgEncode:Message = new Message();
                    msgEncode.type = 'encode';
                    msgEncode.value = [ ba, config ];

                    MonsterDebugger.trace( me, 'start encoding' );
                    inputChn.send(msgEncode)
                }
            });

            MonsterDebugger.trace( me, 'kick off worker' );
            workerBackground.start();

            return prmEncoding;
        }
    }
}