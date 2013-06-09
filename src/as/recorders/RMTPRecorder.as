package recorders
{
    // flash built in
    import flash.net.*;
    import flash.events.NetStatusEvent;
    import flash.media.Microphone;
    import flash.utils.*;

    // 3rd party
    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    // self created
    import helpers.StateMachine;
    import events.StatusEvent;
    import events.RecorderEvent;
    import recorders.Recorder;
    import connectors.IConnectable;
    import tickets.Ticket;
    import tickets.GUIDTicket;
    import guids.GUID;

    public class RMTPRecorder 
        extends Recorder 
        implements IConnectable
    {
        private const defaultSetting:Object = 
        {
            server: ''
        };

        private var _conn:NetConnection;
        private var _stream:NetStream;

        private var _currentGUID:GUID;
        private var _stateMachine:StateMachine;

        private var _dfdConnect:Deferred;
        private var _dfdRecord:Deferred;
        private var _dfdBufferEmpty:Deferred;
        private var _queueGUID:Vector.<GUID> = new Vector.<GUID>();

        public var config:Object;

        private function fireDisconnect():void
        {
            var evt:RecorderEvent = new RecorderEvent(RecorderEvent.DISCONNECTED, _currentGUID);
            dispatchEvent( evt );
        }

        // Handlers

        private function onStateIdle(event:StatusEvent):void
        {
            MonsterDebugger.trace(this, 'status changed to idle');

            _currentGUID = null;
        }

        private function onStateConnect(event:StatusEvent):void
        {
            var server:String = '';
            var params:Array;

            MonsterDebugger.trace(this, 'status changed to connect');

            if (event.targetStatus == 'disconnect' || event.targetStatus == 'stop_stream')
            {
                return;
            }

            if (_conn != null && _conn.connected)
            {
                return;
            }

            MonsterDebugger.trace(this, 'pop guid');

            // record current guid
            _currentGUID = _queueGUID.pop();
            
            _dfdConnect = new Deferred();

            server = config['server'];

            params = getConnectionParams();

            // append must have params
            params.unshift(server, _currentGUID.toString());

            MonsterDebugger.trace(this, 'connection parameters:');
            MonsterDebugger.trace(this, params);

            disposeConnection();

            _conn = new NetConnection();
            // TODO: handle timeout?
            _conn.connect.apply(_conn, params);
            _conn.addEventListener(NetStatusEvent.NET_STATUS, onConnStatus);
            _conn.client = {};

            event.promise = _dfdConnect.promise;

            _dfdConnect.promise.then(function():void
            {
                var evt:RecorderEvent = new RecorderEvent(RecorderEvent.CONNECTED, _currentGUID);
                dispatchEvent( evt );
            });

        }

        private function onStateStartStream(event:StatusEvent):void
        {
            MonsterDebugger.trace(this,  'status changed to start_stream');

            if (event.targetStatus != 'start_stream')
            {

                MonsterDebugger.trace(this,  
                    'target status is not start_stream, so that means we do not need to do anything');
                return;
            }

            MonsterDebugger.trace(this,  'check connection status');

            if (_conn != null && _conn.connected)
            {

                MonsterDebugger.trace(this,  'connected already');

                MonsterDebugger.trace(this,  'start streaming..., guid: ' + _currentGUID);

                _dfdRecord = new Deferred();
                
                _stream = new NetStream(_conn);
                _stream.attachAudio(_mic);
                _stream.publish(_currentGUID.toString(), "record");

                var evt:RecorderEvent = new RecorderEvent(RecorderEvent.STARTED, _currentGUID);
                dispatchEvent( evt );

            }
            else
            {

                MonsterDebugger.trace(this,  'not connected, wait for connected');
                
                throw new Error('connection is not established');

            }
        }

        private function onStateStopStream(event:StatusEvent):void
        {
            MonsterDebugger.trace(this, 'status changed to stop_stream, targetStatus is ' + event.targetStatus);
            
            if (_stream == null)
            {
                return;
            }

            // wait for buffer flushed
            var dfd:Deferred = new Deferred();

            if (_stream.bufferLength <= 0)
            {
                setTimeout(function():void
                {
                    dfd.resolve(null);
                }, 1000);
            }
            else
            {
                _dfdBufferEmpty = new Deferred();
                dfd.resolve(_dfdBufferEmpty.promise);
            }
            
            dfd
                .promise
                .then(function():void
                {
                    _stream.close();

                    MonsterDebugger.trace(this, 'stream closed');

                    var evt:RecorderEvent = new RecorderEvent(RecorderEvent.STOPPED, _currentGUID);
                    dispatchEvent( evt );
                });

            if (_dfdRecord)
            {
                _dfdRecord
                    .resolve( dfd.promise );
                _dfdRecord
                    .promise.then(function():void
                    {
                        _dfdRecord = null;
                    });

                event.promise = _dfdRecord.promise;
            }
        }

        private function onStateDisconnect(event:StatusEvent):void
        {
            MonsterDebugger.trace(this, 'status changed to disconnect');

            // why disconnect it when we want to redo the recording again?
            if (event.targetStatus != 'disconnect' && event.targetStatus != 'idle')
            {
                return;
            }
            
            if (_conn == null)
            {

                MonsterDebugger.trace(this, 'no connection, nothing to close');
                return;

            }

            MonsterDebugger.trace(this, 'closing connection...');

            _conn.close();

            fireDisconnect();
        }

        private function onConnStatus(event:NetStatusEvent):void
        {
            MonsterDebugger.trace(this,  'net connection status changed, info.code: ' + event.info.code);

            if (event.info.code == "NetConnection.Connect.Success")
            {
                _dfdConnect.resolve(null);
            }
            
            else if (event.info.code == "NetConnection.Connect.Failed")
            {
                
                _dfdConnect.reject(event.info.code);

                if (_conn)
                {
                    _conn.close();
                }

                _stateMachine.gotoStatus('idle');

            }
            
            else if (event.info.code == "NetConnection.Connect.Closed")
            {
                disposeConnection();
            }
        }

        private function onStreamStatus(event:NetStatusEvent):void
        {
            MonsterDebugger.trace(this,  'net stream status changed, info.code: ' + event.info.code);

            if (event.info.code == "NetStream.Buffer.Empty")
            {
                if (_dfdBufferEmpty != null)
                {
                    _dfdBufferEmpty.resolve( null );
                }
                _dfdBufferEmpty = null;
            }
        }

        private function disposeConnection():void
        {
            if (!_conn)
            {
                return;
            }
            
            try
            {
                _conn.close();
            }
            catch(ex:*)
            {

            }

            _conn = null;
        
        }

        protected function getConnectionParams():Array
        {
            return [];
        }

        function RMTPRecorder(mic:Microphone, cfg:Object)
        {
            config = cfg;
            super(mic, cfg);

            for(var key:String in defaultSetting)
            {
                if (!(key in config))
                {
                    config[key] = defaultSetting[key];
                }
            }

            _stateMachine = new StateMachine
            ([
                'idle',
                'connect',
                'start_stream',
                'stop_stream',
                'disconnect'
            ]);

            _stateMachine.addEventListener('idle', onStateIdle);
            _stateMachine.addEventListener('connect', onStateConnect);
            _stateMachine.addEventListener('start_stream', onStateStartStream);
            _stateMachine.addEventListener('stop_stream', onStateStopStream);
            _stateMachine.addEventListener('disconnect', onStateDisconnect);
        }

        public function connect():Ticket
        {
            var ret:GUIDTicket;
            var prm:Promise;
            var dfd:Deferred = new Deferred();            

            ret = new GUIDTicket(dfd.promise);

            _queueGUID.push(ret.guid);

            prm = _stateMachine.gotoStatus('connect');

            dfd.resolve(prm);

            return ret;
        }

        public function disconnect():Ticket
        {
            var ret:GUIDTicket;
            var prm:Promise;

            prm = _stateMachine.gotoStatus('disconnect');

            ret = new GUIDTicket(prm, _currentGUID);

            return ret;
        }

        public override function start():Ticket
        {
            var ret:GUIDTicket;
            var prm:Promise;
            var dfd:Deferred = new Deferred();   

            ret = new GUIDTicket(dfd.promise, _currentGUID);

            if (_currentGUID == null)
            {
                _currentGUID = ret.guid;
            }

            prm = _stateMachine.gotoStatus('start_stream');

            dfd.resolve(prm);

            return ret;
        }

        public override function record():Ticket
        {
            var ret:GUIDTicket;
            var prmStarted:Promise;
            var dfd:Deferred = new Deferred();

            prmStarted = _stateMachine.gotoStatus('start_stream');

            ret = new GUIDTicket(dfd.promise, _currentGUID);

            prmStarted.then(function():void
            {
                // resolve dfd when _dfdRecord resolved
                dfd.resolve(_dfdRecord.promise);
            });

            return ret;
        }

        public override function stop():Ticket
        {
            var ret:GUIDTicket;
            var prm:Promise;

            prm = _stateMachine.gotoStatus('stop_stream');

            ret = new GUIDTicket(prm, _currentGUID);

            return ret;
        }

        public override function dispose():void
        {
            disconnect();
        }

        public override function get activity():Number
        {
            if (_mic == null)
            {
                return 0;
            }

            return _mic.activityLevel;
        }


    }
}