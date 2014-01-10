package players
{
    import tickets.Ticket;
    import tickets.GUIDTicket;
    import events.PlayerEvent;
    import players.Player;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.demonsters.debugger.MonsterDebugger;
    import guids.GUID;

    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;

    public class FilePlayer extends Player
    {
        private var _stream:NetStream;
        private var _conn:NetConnection;
        private var _dfdPlay:Deferred;
        private var _dfdConnReady:Deferred = new Deferred();
        private var _streamClient:Object = {};
        private var _guidPlaying:GUID;

        public var readyState:Number = 1;
        public var duration:Number;

        private function onConnStreamStatus(event:NetStatusEvent):void
        {
            MonsterDebugger.trace(this, 
                'player conn and stream status changed' + event.info.code);

            switch ( event.info.code )
            {
                case "NetConnection.Connect.Success":
                    connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                case "NetStream.Play.Stop":
                    onStop();
                default:
                    break;
            }
        }

        private function onConnSecurityError(event:SecurityErrorEvent):void
        {
            MonsterDebugger.trace(this, 'a security error raised');
        }

        private function connectStream():void 
        {
            _streamClient.onMetaData = onMetaData;

            _stream = new NetStream(_conn);
            _stream.addEventListener(NetStatusEvent.NET_STATUS, onConnStreamStatus);
            _stream.client = _streamClient;

            _dfdConnReady.resolve( null );
        }

        private function onStop():void
        {
            _stream.close();

            dispatchEvent( new PlayerEvent( PlayerEvent.STOPPED, _guidPlaying ) );

            _guidPlaying = null;
        }

        private function onMetaData( data:Object ):void
        {
            duration = data.duration;
            readyState = 1;
        }

        function FilePlayer(cfg:Object)
        {
            super(cfg);

            _conn = new NetConnection();
            _conn.addEventListener
            (
                NetStatusEvent.NET_STATUS, 
                onConnStreamStatus
            );
            _conn.addEventListener
            (
                SecurityErrorEvent.SECURITY_ERROR, 
                onConnSecurityError
            );
            _conn.connect( null );
        }

        public override function start( path:* ):Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:GUIDTicket = new GUIDTicket(dfd.promise);

            if ( _guidPlaying != null )
            {
                ret.guid = _guidPlaying;
            }
            else
            {
                _guidPlaying = ret.guid;
            }


            _dfdPlay = new Deferred();
            readyState = 0;

            dfd.resolve
            (
                _dfdConnReady.promise
                .then(function():void
                {
                    _stream.play( String( path ) );
                    _stream.seek( 0 );

                    dispatchEvent( new PlayerEvent( PlayerEvent.STARTED, _guidPlaying ) );
                })
            );

            return ret;
        }

        public override function play( path:* ):Ticket
        {
            var ret:GUIDTicket = new GUIDTicket( _dfdPlay.promise );
            _guidPlaying = ret.guid;

            start( path );

            return ret;
        }

        public override function stop():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:Ticket = new Ticket(dfd.promise);

            dfd.resolve
            (
                _dfdConnReady.promise
                .then(function():void
                {   
                    onStop();
                })
            );

            dfd.resolve( null );

            if ( _dfdPlay )
            {
                _dfdPlay.resolve( null );
            }

            return ret;
        }

        public override function dispose():void
        {
            _stream.close();
            _conn.close();

            super.dispose();
        }
    }
}