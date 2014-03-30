package interoperators
{
    import flash.external.ExternalInterface;
    import flash.utils.ByteArray;

    import interoperators.Factory;
    import connectors.IConnectable;
    import Playcorder;
    import events.RecorderEvent;
    import events.RecorderErrorEvent;
    import events.RecorderChangeEvent;
    import events.PlayerEvent;
    import tickets.Ticket;
    import tickets.GUIDTicket;
    import data.containers.RAWAudioContainer;
    import guids.GUID;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;

    public class UniversalInteroperator extends Interoperator
    {
        public static const MEMBER_NAME:Object = {
            RECORDER_ONCONNECTED                    : 'recorder_onconnected',
            RECORDER_ONDISCONNECTED                 : 'recorder_ondisconnected',
            RECORDER_ONSTARTED                      : 'recorder_onstarted',
            RECORDER_ONSTOPPED                      : 'recorder_onstopped',
            RECORDER_ONERROR                        : 'recorder_onerror',
            RECORDER_ONCHANGE                       : 'recorder_onchange',
            RECORDER_CONNECT                        : 'recorder_connect',
            RECORDER_DISCONNECT                     : 'recorder_disconnect',
            RECORDER_START                          : 'recorder_start',
            RECORDER_STOP                           : 'recorder_stop',
            RECORDER_ACTIVITY                       : 'recorder_activity',
            RECORDER_MUTED                          : 'recorder_muted',
            RECORDER_INITIALIZE                     : 'recorder_initialize',
            RECORDER_RESULT_TYPE                    : 'recorder_result_type',
            RECORDER_RESULT_DOWNLOAD                : 'recorder_result_download',
            RECORDER_RESULT_ONDOWNLOADED            : 'recorder_result_ondownloaded',
            RECORDER_RESULT_ONDOWNLOADFAILED        : 'recorder_result_ondownloadfailed',
            RECORDER_RESULT_UPLOAD                  : 'recorder_result_upload',
            RECORDER_RESULT_ONUPLOADED              : 'recorder_result_onuploaded',
            RECORDER_RESULT_ONUPLOADFAILED          : 'recorder_result_onuploadfailed',
            RECORDER_RESULT_ONUPLOADINTERACTION     : 'recorder_result_onuploadinteraction',
            RECORDER_RESULT_DURATION                : 'recorder_result_duration',
            RECORDER_RESULT_INTERACT                : 'recorder_result_interact',
            PLAYER_ONSTARTED                        : 'player_onstarted',
            PLAYER_ONSTOPPED                        : 'player_onstopped',
            PLAYER_START                            : 'player_start',
            PLAYER_STOP                             : 'player_stop',
            PLAYER_INITIALIZE                       : 'player_initialize',
            ONREADY                                 : 'onready',
            ONISREADY                               : 'onisready',
            ONLOADED                                : 'onloaded',
            GETID                                   : 'getID',
            PREPARE                                 : 'prepare'
        };

        private var _inited:Boolean = false;
        private var _findSelf:String;
        protected var _guid:GUID;
        private var _dfdInteraction:Object = null;

        private function secure(func:Function):Function
        {
            var me:Interoperator = this;
            return function():*
            {
                if ( disabled ) 
                {
                    return;
                }

                return func.apply(me, arguments);
            }
        }

        private function getExternalByteArray(ba:ByteArray):*
        {
            var outputArray:Array;
            var count:int = 0;

            MonsterDebugger.trace( this, 'copying byte array' );

            outputArray = [0];
            outputArray.length = ba.length;

            ba.position = 0;

            while( ba.bytesAvailable > 0 )
            {
                outputArray[count++] = ba.readUnsignedByte();
            }
            
            MonsterDebugger.trace( this, 'copying byte array: done' );

            return outputArray;
        }

        private function onRecorderConnected(event:RecorderEvent):void
        {
            callSelf(MEMBER_NAME.RECORDER_ONCONNECTED, 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderDisconnected(event:RecorderEvent):void
        {
            callSelf(MEMBER_NAME.RECORDER_ONDISCONNECTED, 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderStarted(event:RecorderEvent):void
        {
            callSelf(MEMBER_NAME.RECORDER_ONSTARTED, 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderStopped(event:RecorderEvent):void
        {
            callSelf(MEMBER_NAME.RECORDER_ONSTOPPED, 
            {
                'guid': event.guid.toString()
            })
        }

        private function onRecorderError(event:RecorderErrorEvent):void
        {
            callSelf(MEMBER_NAME.RECORDER_ONERROR,
            {
                'guid': event.guid ? event.guid.toString():'',
                'code': event.code
            })
        }

        private function onRecorderChange(event:RecorderChangeEvent):void
        {
            callSelf(MEMBER_NAME.RECORDER_ONCHANGE,
            {
                'code': event.code
            })
        }

        private function onPlayerStarted(event:PlayerEvent):void
        {
            callSelf(MEMBER_NAME.PLAYER_ONSTARTED, 
            {
                'guid': event.guid ? event.guid.toString():''
            })
        }

        private function onPlayerStopped(event:PlayerEvent):void
        {
            callSelf(MEMBER_NAME.PLAYER_ONSTOPPED, 
            {
                'guid': event.guid ? event.guid.toString():''
            })
        }

        protected function callSelf(methodName:String, ... args:*):void
        {
            if ( disabled )
            {
                return;
            }

            MonsterDebugger.trace(this, 'trigger ' + methodName);

            ExternalInterface.call.apply
            (
                ExternalInterface, 
                [ _findSelf , methodName ].concat(args)
            );

            MonsterDebugger.trace(this, 'trigger ' + methodName + ':done');
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

            ExternalInterface.addCallback(MEMBER_NAME.PLAYER_START, function(source:* = null):String
            {
                MonsterDebugger.trace(this, 'external calls to player.start()');

                var ticket:GUIDTicket = playcorder.player.start( source ) as GUIDTicket;

                return ticket != null ? ticket.guid.toString() : '';
            });

            ExternalInterface.addCallback(MEMBER_NAME.PLAYER_STOP, function():String
            {
                MonsterDebugger.trace(this, 'external calls to player.stop()');

                var ticket:GUIDTicket = playcorder.player.stop() as GUIDTicket;

                return ticket != null ? ticket.guid.toString() : '';
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_START, function():String
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

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_STOP, function():void
            {
                
                MonsterDebugger.trace(this, 'external calls to recorder.stop()');

                playcorder.recorder.stop();
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_ACTIVITY, function():Number
            {

                var ret:Number = 0;

                if (playcorder.recorder && playcorder.recorder.microphone){
                    ret = playcorder.recorder.microphone.activityLevel;
                }

                return ret;
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_MUTED, function():Boolean
            {
                var ret:Boolean = true;

                MonsterDebugger.trace(this, 'external calls to recorder.muted()');

                if (playcorder.recorder && playcorder.recorder.microphone){
                    ret = playcorder.recorder.microphone.muted;
                }

                return ret;
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_CONNECT, function(...args):String
            {
                var ret:String = '';

                if (playcorder.recorder is IConnectable)
                {
                    var connectable:IConnectable = IConnectable(playcorder.recorder);

                    MonsterDebugger.trace(this, 'external calls to recorder.connect()');

                    var ticket:Ticket = connectable.connect(args);

                    if (ticket is GUIDTicket)
                    {
                        ret = GUIDTicket(ticket).guid.toString();
                    }
                }

                return ret;
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_DISCONNECT, function():void
            {
                if (playcorder.recorder is IConnectable)
                {
                    var connectable:IConnectable = IConnectable(playcorder.recorder);

                    MonsterDebugger.trace(this, 'external calls to recorder.disconnect()');

                    connectable.disconnect();
                }
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_INITIALIZE, function(config:Object):Boolean
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

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_RESULT_TYPE, function():String
            {
                var ret:String = '';

                MonsterDebugger.trace(this, 'external calls to recorder.result.type()');

                if ( playcorder.recorder && playcorder.recorder.result )
                {
                    ret = playcorder.recorder.result.type;
                }

                return ret;
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_RESULT_DOWNLOAD, function(type:String = "raw"):String
            {
                var ret:String = '';
                var ticket:Ticket;
                var guidTicket:GUIDTicket;

                MonsterDebugger.trace(this, 'external calls to recorder.result.download()');

                if ( playcorder.recorder && playcorder.recorder.result )
                {
                    
                    ticket = playcorder.recorder.result.download( type );

                    if ( ticket is GUIDTicket )
                    {
                        guidTicket = GUIDTicket(ticket);
                        ret = guidTicket.guid.toString();

                        guidTicket
                            .promise
                            .then(
                                function(obj:Object):void
                                {
                                    var ba:ByteArray = obj.data as ByteArray;
                                    var result:*;

                                    if ( ba == null )
                                    {
                                        callSelf
                                        (
                                            MEMBER_NAME.RECORDER_RESULT_ONDOWNLOADFAILED,
                                            {
                                                guid: ret,
                                                message: 'encoding failed, no properly ByteArray returned.'
                                            }
                                        );
                                        return;
                                    }

                                    try
                                    {
                                        result = getExternalByteArray(ba);
                                    }
                                    catch(ex:*)
                                    {
                                        callSelf
                                        (
                                            MEMBER_NAME.RECORDER_RESULT_ONDOWNLOADFAILED,
                                            {
                                                guid: ret,
                                                message: 'encoding failed:' + ex.toString()
                                            }
                                        );
                                        return;
                                    }

                                    nextTick(function():void
                                    {
                                        callSelf(
                                            MEMBER_NAME.RECORDER_RESULT_ONDOWNLOADED,
                                            {
                                                guid: ret,
                                                data: result,
                                                length: obj.length,
                                                channels: obj.channels,
                                                rate: obj.rate
                                            }
                                        );
                                    })
                                },
                                function(msg:String):void
                                {
                                    nextTick(function():void
                                    {
                                        callSelf(
                                            MEMBER_NAME.RECORDER_RESULT_ONDOWNLOADFAILED,
                                            {
                                                guid: ret,
                                                message: msg != null? msg: "unknown error"
                                            }
                                        );
                                    })
                                }
                            );


                    }
                }

                return ret;
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_RESULT_UPLOAD, function(type:String, url:String, options:Object = null):String
            {
                var ret:String = '';
                var ticket:Ticket;

                MonsterDebugger.trace(this, 'external calls to recorder.result.upload()');

                if ( playcorder.recorder && playcorder.recorder.result )
                {
                    ticket = playcorder.recorder.result.upload(type, url, options);

                    if ( ticket is GUIDTicket )
                    {
                        ret = GUIDTicket(ticket).guid.toString();
                    }

                    ticket
                        .promise
                        .then(function(obj:Object):*
                        {
                            // a uesr interaction is required
                            if ( obj != null && obj['deferred'] != null )
                            {
                                _dfdInteraction = obj['deferred'];

                                nextTick(function():void
                                {
                                    callSelf
                                    (
                                        MEMBER_NAME.RECORDER_RESULT_ONUPLOADINTERACTION
                                    );
                                });

                                return obj['promise'];
                            }
                            
                            return obj;
                        })
                        .then(
                            function():void
                            {
                                nextTick(function():void
                                {
                                    callSelf(
                                        MEMBER_NAME.RECORDER_RESULT_ONUPLOADED,
                                        {
                                            guid: ret,
                                            api: url
                                        }
                                    );
                                });
                            },
                            function(msg:String):void
                            {
                                nextTick(function():void
                                {
                                    callSelf(
                                        MEMBER_NAME.RECORDER_RESULT_ONUPLOADFAILED,
                                        {
                                            guid: ret,
                                            message: msg != null ? msg : "unknown error"
                                        }
                                    );
                                });
                            });
                }

                return ret;
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_RESULT_INTERACT, function():void
            {
                MonsterDebugger.trace(this, 'external calls to recorder.result.interact()');

                if ( _dfdInteraction != null )
                {
                    MonsterDebugger.trace(this, 'an waiting interact is found, resume it');

                    if ( _dfdInteraction['resolve'] != null )
                    {
                        _dfdInteraction['resolve']( null );
                    }

                    _dfdInteraction = null;
                }
            });

            ExternalInterface.addCallback(MEMBER_NAME.RECORDER_RESULT_DURATION, function():int
            {
                MonsterDebugger.trace(this, 'external calls to recorder.result.duration()');

                if ( playcorder.recorder && playcorder.recorder.result && playcorder.recorder.result is RAWAudioContainer )
                {
                    return RAWAudioContainer(playcorder.recorder.result).duration;
                }

                return 0;
            });

            ExternalInterface.addCallback(MEMBER_NAME.PLAYER_INITIALIZE, function(config:Object):Boolean
            {
                MonsterDebugger.trace(this, 'external calls to player_initialize()');

                var ret:Boolean = playcorder.init_player(config);

                playcorder.player.addEventListener(PlayerEvent.STARTED, onPlayerStarted);
                playcorder.player.addEventListener(PlayerEvent.STOPPED, onPlayerStopped);

                MonsterDebugger.trace(playcorder.player, 'Player events are attached.');

                return ret;
            });

            ExternalInterface.addCallback(MEMBER_NAME.PREPARE, function():Boolean
            {
                return playcorder.prepare();
            });

            ExternalInterface.addCallback(MEMBER_NAME.GETID, function():String
            {
                return _guid.toString();
            });

            // fire loaded first, this call must be after the definition of GETID, otherwise findSelf will not work
            callSelf( MEMBER_NAME.ONLOADED );

            _inited = true;

            // resolve when the super class is inited.
            dfd.resolve(super.init());

            return dfd.promise;
        }

        protected override function onReady():void
        {
            // fire ready event when it is ready
            callSelf( MEMBER_NAME.ONREADY );
            // fire internal used ready event
            callSelf( MEMBER_NAME.ONISREADY );
        }

        protected function getFuncToInvokeExternalHostMethod(id:String):String
        {
            return "";
        }

        public function UniversalInteroperator(playcorder:Playcorder)
        {
            _guid = GUID.create();
            _findSelf = getFuncToInvokeExternalHostMethod( _guid.toString() );

            super(playcorder);

            // data must be set after super(), otherwise it will be null
            data['id'] = _guid;
        }
    }
}