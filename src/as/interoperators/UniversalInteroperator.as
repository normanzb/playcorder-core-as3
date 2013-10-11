package interoperators
{
    import flash.external.ExternalInterface;

    import interoperators.Factory;
    import connectors.IConnectable;
    import Playcorder;
    import events.RecorderEvent;
    import events.RecorderErrorEvent;
    import events.RecorderChangeEvent;
    import events.PlayerEvent;
    import tickets.Ticket;
    import tickets.GUIDTicket;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    public class UniversalInteroperator extends Interoperator
    {
        private static var instanceCount:Number = 0;

        private var _inited:Boolean = false;
        private var _count:Number = 0;
        private var _findSelf:String;

        private function onRecorderConnected(event:RecorderEvent):void
        {
            callSelf('recorder_onconnected', 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderDisconnected(event:RecorderEvent):void
        {
            callSelf('recorder_ondisconnected', 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderStarted(event:RecorderEvent):void
        {
            callSelf('recorder_onstarted', 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderStopped(event:RecorderEvent):void
        {
            callSelf('recorder_onstopped', 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderError(event:RecorderErrorEvent):void
        {
            callSelf('recorder_onerror',
            {
                'guid': event.guid ? event.guid.toString():'',
                'code': event.code
            })
        }

        private function onRecorderChange(event:RecorderChangeEvent):void
        {
            callSelf('recorder_onchange',
            {
                'code': event.code
            })
        }

        private function onPlayerStarted(event:PlayerEvent):void
        {
            callSelf('player_onstarted', 
            {
            })
        }

        private function onPlayerStopped(event:PlayerEvent):void
        {
            callSelf('player_onstopped', 
            {
            })
        }

        protected function callSelf(methodName:String, ... args:*):void
        {
            ExternalInterface.call.apply
            (
                ExternalInterface, 
                [ _findSelf , methodName ].concat(args)
            );
        }  

        // override the init method, setup callbacks and expose member methods
        protected override function init():Promise
        {
            var dfd:Deferred = new Deferred();

            if (_inited || !ExternalInterface.available)
            {
                dfd.resolve( null );
                return dfd.promise;
            }

            ExternalInterface.addCallback("player_start", function(path:String):void
            {
                MonsterDebugger.trace(this, 'external calls to player.start()');

                playcorder.player.start( path );
            });

            ExternalInterface.addCallback("player_stop", function():void
            {
                MonsterDebugger.trace(this, 'external calls to player.stop()');

                playcorder.player.stop();
            });

            ExternalInterface.addCallback("recorder_start", function():String
            {
                var ret:String = '';

                MonsterDebugger.trace(this, 'external calls to recorder.start()');

                var ticket:Ticket = playcorder.recorder.start();

                if (ticket is GUIDTicket)
                {
                    ret = GUIDTicket(ticket).guid.toString();
                }

                return ret;
            });

            ExternalInterface.addCallback("recorder_stop", function():void
            {
                
                MonsterDebugger.trace(this, 'external calls to recorder.stop()');

                playcorder.recorder.stop();
            });

            ExternalInterface.addCallback("recorder_activity", function():Number
            {

                var ret:Number = 0;

                if (playcorder.recorder && playcorder.recorder.microphone){
                    ret = playcorder.recorder.microphone.activityLevel;
                }

                return ret;
            });

            ExternalInterface.addCallback("recorder_muted", function():Boolean
            {
                var ret:Boolean = true;

                MonsterDebugger.trace(this, 'external calls to recorder.muted()');

                if (playcorder.recorder && playcorder.recorder.microphone){
                    ret = playcorder.recorder.microphone.muted;
                }

                return ret;
            });

            ExternalInterface.addCallback("recorder_connect", function():String
            {
                var ret:String = '';

                if (playcorder.recorder is IConnectable)
                {
                    var connectable:IConnectable = IConnectable(playcorder.recorder);

                    MonsterDebugger.trace(this, 'external calls to recorder.connect()');

                    var ticket:Ticket = connectable.connect();

                    if (ticket is GUIDTicket)
                    {
                        ret = GUIDTicket(ticket).guid.toString();
                    }
                }

                return ret;
            });

            ExternalInterface.addCallback("recorder_disconnect", function():void
            {
                

                if (playcorder.recorder is IConnectable)
                {
                    var connectable:IConnectable = IConnectable(playcorder.recorder);

                    MonsterDebugger.trace(this, 'external calls to recorder.disconnect()');

                    connectable.disconnect();
                }
            });

            ExternalInterface.addCallback("recorder_initialize", function(config:Object):Boolean
            {

                var ret:Boolean = playcorder.init_recorder(config);

                playcorder.recorder.addEventListener(RecorderEvent.CONNECTED, onRecorderConnected);
                playcorder.recorder.addEventListener(RecorderEvent.DISCONNECTED, onRecorderDisconnected);
                playcorder.recorder.addEventListener(RecorderEvent.STARTED, onRecorderStarted);
                playcorder.recorder.addEventListener(RecorderEvent.STOPPED, onRecorderStopped);
                playcorder.recorder.addEventListener(RecorderEvent.ERROR, onRecorderError);
                playcorder.recorder.addEventListener(RecorderChangeEvent.CHANGE, onRecorderChange);

                return ret;
            });

            ExternalInterface.addCallback("player_initialize", function(config:Object):Boolean
            {
                var ret:Boolean = playcorder.init_player(config);

                playcorder.player.addEventListener(PlayerEvent.STARTED, onPlayerStarted);
                playcorder.player.addEventListener(PlayerEvent.STOPPED, onPlayerStopped);

                return ret;
            });

            ExternalInterface.addCallback("prepare", function():Boolean
            {
                return playcorder.prepare();
            });

            ExternalInterface.addCallback("getID", function():Number
            {
                return _count;
            });

            _inited = true;

            // resolve when the super class is inited.
            dfd.resolve(super.init());

            return dfd.promise;
        }

        protected override function onReady():void
        {
            // fire ready event when it is ready
            callSelf('onready');
        }

        protected function externalInstanceLookup(id:Number):String
        {
            return "";
        }

        public function UniversalInteroperator(playcorder:Playcorder)
        {
            _count = instanceCount++;
            _findSelf = externalInstanceLookup( _count );
            super(playcorder);
        }
    }
}