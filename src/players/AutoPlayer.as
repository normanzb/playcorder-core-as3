package players
{
    import players.Player;
    import players.FilePlayer;
    import players.LocalPlayer;

    import tickets.Ticket;
    import events.PlayerEvent;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.demonsters.debugger.MonsterDebugger;

    public class AutoPlayer extends Player
    {
        private var _player:Player;
        private var _config:Object;

        function AutoPlayer(cfg:Object)
        {
            super(cfg);

            _config = cfg;
        }

        private function handleEventRedirect(evt:PlayerEvent):void
        {
            MonsterDebugger.trace(evt, 'sub player event redirect: ' + evt.type );

            dispatchEvent( new PlayerEvent(evt.type, evt.guid) );
        }

        private function initSubPlayer(source:*):void
        {
            var sourceType:String = typeof source;

            if ( _player != null )
            {
                _player.stop();
                _player.dispose();
                _player = null;
            }

            switch(sourceType)
            {
                case 'string':
                    _player = new FilePlayer( _config );
                    break;
                case 'object':
                default:
                    _player = new LocalPlayer( _config );
                    break;
            }

            _player.addEventListener( PlayerEvent.STARTED, handleEventRedirect );
            _player.addEventListener( PlayerEvent.STOPPED, handleEventRedirect );
        }

        private function tryCall( method:String, ...args ):Ticket
        {
            var ret:Ticket;

            MonsterDebugger.trace(this, 'trying to call sub player.' + method );

            if ( _player == null )
            {
                var dfd:Deferred = new Deferred();
                ret = new Ticket(dfd.promise);

                dfd.resolve( null );
            }
            else
            {
                ret = _player[method].apply(_player, args) as Ticket;
            }

            MonsterDebugger.trace(this, 'trying to call sub player.' + method + ':done' );

            return ret;
        }

        public override function start(source:*):Ticket
        {
            initSubPlayer( source );

            return tryCall('start', source);
        }

        public override function play(source:*):Ticket
        {
            initSubPlayer( source );

            return tryCall('play', source);
        }

        public override function stop():Ticket
        {
            return tryCall('stop');
        }

        public override function dispose():void
        {
            tryCall('dispose');
        }
    }
}