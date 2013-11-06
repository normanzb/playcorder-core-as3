package workers.encoders
{
    import flash.utils.ByteArray;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.registerClassAlias;
    import flash.system.MessageChannel;
    import flash.system.Worker;

    import workers.messages.Message;

    import fr.kikko.lab.ShineMP3Encoder;
    import im.norm.data.encoders.WaveEncoder;
    import com.codecatalyst.util.*;
    import com.demonsters.debugger.MonsterDebugger;

    public class MP3
        extends Base
    {
        protected override function handleEncode(...args):void
        {
            var me:Base = this;

            var waveEncoder:WaveEncoder = new WaveEncoder();
            var mp3Encoder:ShineMP3Encoder;
            var bytes:ByteArray;
            var prg:Message = new Message();
            
            prg.type = 'progress';
            prg.value = 0;

            // send progress 0% as start signal
            outputChannel.send( prg );

            MonsterDebugger.trace( me, 'encoding mp3: encoding to wave' );

            bytes = waveEncoder.encode.apply(waveEncoder, args);

            prg.value = 50;

            // send progress 50% as end signal of encoding wave
            outputChannel.send( prg );

            mp3Encoder = new ShineMP3Encoder( bytes );

            mp3Encoder.addEventListener(Event.COMPLETE, function(evt:Event):void
            {
                MonsterDebugger.trace( me, 'encoding mp3: completed' );

                prg.value = 100;

                // send progress 100% as end signal of encoding mp3
                outputChannel.send( prg );

                nextTick(function():void
                {
                    MonsterDebugger.trace( me, 'try to send the encoding result data' );

                    var result:Message = new Message();
                    result.type = 'result';
                    result.value = mp3Encoder.mp3Data;

                    // send encoded result
                    outputChannel.send( result );
                });
            });

            MonsterDebugger.trace( me, 'encoding mp3: starting' );
            mp3Encoder.start();
        }
    }
}