package recorders
{
    // flash built in
    import flash.media.Microphone;
    import flash.events.SampleDataEvent;
    import flash.utils.ByteArray;

    // 3rd party
    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;

    import helpers.StateMachine;
    import events.StatusEvent;
    import events.RecorderEvent;
    import recorders.Recorder;
    import tickets.Ticket;
    import tickets.GUIDTicket;
    import data.containers.Container;
    import data.containers.RAWAudioContainer;
    import guids.GUID;

    public class LocalRecorder 
        extends Recorder 
    {
        private var _stateMachine:StateMachine = new StateMachine(['idle', 'start', 'record', 'stop']);
        private var _dfdRecording:Deferred;
        private var _buffer:ByteArray;
        private var _result:RAWAudioContainer;
        private var _currentGUID:GUID;
        private var _queueGUID:Vector.<GUID> = new Vector.<GUID>();

        private function onSampleData(event:SampleDataEvent):void
        {
            while( event.data.bytesAvailable > 0 )
            {
                _buffer.writeFloat(event.data.readFloat());
            }
        }

        private function onStateIdle(event:StatusEvent):void
        {
            _dfdRecording = null;
            _result = null;
            _currentGUID = null;
        }

        private function onStateStart(event:StatusEvent):void
        {
            var me:LocalRecorder = this;

            MonsterDebugger.trace(me, 'status changed to start');

            _dfdRecording = new Deferred();
            _buffer = new ByteArray();
            _currentGUID = _queueGUID.shift();

            _mic.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );

            nextTick(function():void
            {
                MonsterDebugger.trace(me, 'dispatch started');
                var evt:RecorderEvent = new RecorderEvent(RecorderEvent.STARTED, _currentGUID);
                dispatchEvent( evt );
            });
        }

        private function onStateRecord(event:StatusEvent):void
        {
            
        }

        private function onStateStop(event:StatusEvent):void
        {
            var me:LocalRecorder = this;

            MonsterDebugger.trace(me, 'status changed to stop');

            _mic.removeEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );

            _result = new RAWAudioContainer( _mic );
            _result.data = _buffer;

            nextTick(function():void
            {
                MonsterDebugger.trace(me, 'dispatch stopped');
                var evt:RecorderEvent = new RecorderEvent(RecorderEvent.STOPPED, _currentGUID);
                dispatchEvent( evt );
            });
        }

        function LocalRecorder(mic:Microphone, config:Object)
        {
            _stateMachine.addEventListener('idle', onStateIdle);
            _stateMachine.addEventListener('start', onStateStart);
            _stateMachine.addEventListener('record', onStateRecord);
            _stateMachine.addEventListener('stop', onStateStop);

            super( mic, config );
        }

        public override function start():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:GUIDTicket = new GUIDTicket(dfd.promise);
            _queueGUID.push( ret.guid );

            // resolve when it is 'started'
            dfd.resolve( _stateMachine.gotoStatus("start") );

            return ret;
        }

        public override function record():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:GUIDTicket = new GUIDTicket(dfd.promise);

            _stateMachine
                .gotoStatus("start")
                    .then(function():void
                    {
                        // resolve when it is 'recorded'
                        dfd.resolve( _dfdRecording.promise );
                    });

            return ret;
        }

        public override function stop():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:GUIDTicket = new GUIDTicket(dfd.promise);

            // resolve when it is 'stopped'
            dfd.resolve( _stateMachine.gotoStatus("stop") );

            return ret;
        }

        public override function get result():Container
        {
            return _result;
        }
    }
}