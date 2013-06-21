package interoperators
{
    import flash.external.ExternalInterface;

    import interoperators.Factory;
    import connectors.IConnectable;
    import AudioHelper;
    import events.RecorderEvent;
    import events.RecorderErrorEvent;
    import events.RecorderChangeEvent;
    import events.PlayerEvent;
    import tickets.Ticket;
    import tickets.GUIDTicket;

    import com.demonsters.debugger.MonsterDebugger;

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

        protected override function init():void
        {
            if (_inited || !ExternalInterface.available)
            {
                return;
            }

            ExternalInterface.addCallback("player_start", function(path:String):void
            {
                MonsterDebugger.trace(this, 'external calls to player.start()');

                audioHelper.player.start( path );
            });

            ExternalInterface.addCallback("player_stop", function():void
            {
                MonsterDebugger.trace(this, 'external calls to player.stop()');

                audioHelper.player.stop();
            });

            ExternalInterface.addCallback("recorder_start", function():String
            {
                var ret:String = '';

                MonsterDebugger.trace(this, 'external calls to recorder.start()');

                var ticket:Ticket = audioHelper.recorder.start();

                if (ticket is GUIDTicket)
                {
                    ret = GUIDTicket(ticket).guid.toString();
                }

                return ret;
            });

            ExternalInterface.addCallback("recorder_stop", function():void
            {
                
                MonsterDebugger.trace(this, 'external calls to recorder.stop()');

                audioHelper.recorder.stop();
            });

            ExternalInterface.addCallback("recorder_activity", function():Number
            {

                var ret:Number = 0;

                if (audioHelper.recorder && audioHelper.recorder.microphone){
                    ret = audioHelper.recorder.microphone.activityLevel;
                }

                return ret;
            });

            ExternalInterface.addCallback("recorder_muted", function():Boolean
            {
                var ret:Boolean = true;

                MonsterDebugger.trace(this, 'external calls to recorder.muted()');

                if (audioHelper.recorder && audioHelper.recorder.microphone){
                    ret = audioHelper.recorder.microphone.muted;
                }

                return ret;
            });

            ExternalInterface.addCallback("recorder_connect", function():String
            {
                var ret:String = '';

                if (audioHelper.recorder is IConnectable)
                {
                    var connectable:IConnectable = IConnectable(audioHelper.recorder);

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
                

                if (audioHelper.recorder is IConnectable)
                {
                    var connectable:IConnectable = IConnectable(audioHelper.recorder);

                    MonsterDebugger.trace(this, 'external calls to recorder.disconnect()');

                    connectable.disconnect();
                }
            });

            ExternalInterface.addCallback("recorder_initialize", function(config:Object):Boolean
            {

                var ret:Boolean = audioHelper.init_recorder(config);

                audioHelper.recorder.addEventListener(RecorderEvent.CONNECTED, onRecorderConnected);
                audioHelper.recorder.addEventListener(RecorderEvent.DISCONNECTED, onRecorderDisconnected);
                audioHelper.recorder.addEventListener(RecorderEvent.STARTED, onRecorderStarted);
                audioHelper.recorder.addEventListener(RecorderEvent.STOPPED, onRecorderStopped);
                audioHelper.recorder.addEventListener(RecorderEvent.ERROR, onRecorderError);
                audioHelper.recorder.addEventListener(RecorderChangeEvent.CHANGE, onRecorderChange);

                return ret;
            });

            ExternalInterface.addCallback("player_initialize", function(config:Object):Boolean
            {
                var ret:Boolean = audioHelper.init_player(config);

                audioHelper.player.addEventListener(PlayerEvent.STARTED, onPlayerStarted);
                audioHelper.player.addEventListener(PlayerEvent.STOPPED, onPlayerStopped);

                return ret;
            });

            ExternalInterface.addCallback("prepare", function():Boolean
            {
                return audioHelper.prepare();
            });

            ExternalInterface.addCallback("getID", function():Number
            {
                return _count;
            });

            _inited = true;

        }

        public function UniversalInteroperator(audioHelper:AudioHelper)
        {
            _count = instanceCount++;
            _findSelf = (<![CDATA[
                function audioHelperBuiltinFindHostObject(methodName, arg1, arg2)
                {
                    var id = <ID>;
                    var objs = document.getElementsByTagName('object');
                    var args = Array.prototype.slice.call(arguments, 1);
                    for(var l = objs.length;l--;)
                    {
                        var obj = objs[l];

                        if (!obj || !obj.getID || obj.getID() != id)
                        {
                            continue;
                        }

                        obj[methodName].apply(obj, args);
                        break;
                    }
                }
            ]]>).toString().replace(/\<ID\>/g, _count);
            super(audioHelper);
        }
    }
}