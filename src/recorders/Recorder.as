package recorders
{
    import tickets.Ticket;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.events.StatusEvent;
    import flash.media.Microphone;
    import flash.utils.Timer;

    import events.RecorderChangeEvent;
    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.util.*;
    import data.containers.Container;
    
    public class Recorder extends EventDispatcher implements IRecordable 
    {

        private const defaultSetting:Object = 
        {
            gain: 50,
            rate: 44,
            silence: 0,
            quality: 8
        };
        protected var _mic:Microphone;
        private var config:Object;
        private var timer:Timer;
        private var onMicStatus:Function;

        private var dispatchUnmuted:Function = function():void
        {
            var changeEvent:RecorderChangeEvent =
                new RecorderChangeEvent
                (
                    RecorderChangeEvent.CHANGE, 
                    RecorderChangeEvent.CODE_MIC_UNMUTED
                );
            MonsterDebugger.trace(this, 'dispatch unmute');
            
            nextTick(function():void
            {
                dispatchEvent( changeEvent );
            })
        }

        private var dispatchMuted:Function = function():void
        {
            var changeEvent:RecorderChangeEvent =
                new RecorderChangeEvent
                (
                    RecorderChangeEvent.CHANGE, 
                    RecorderChangeEvent.CODE_MIC_MUTED
                );
            MonsterDebugger.trace(this, 'dispatch mute');
            
            nextTick(function():void
            {
                dispatchEvent( changeEvent );
            })
        }

        private var dispatchNotFound:Function = function():void
        {
            var changeEvent:RecorderChangeEvent =
                new RecorderChangeEvent
                (
                    RecorderChangeEvent.CHANGE, 
                    RecorderChangeEvent.CODE_MIC_NOT_FOUND
                );
            MonsterDebugger.trace(this, 'dispatch not found');
            
            nextTick(function():void
            {
                dispatchEvent( changeEvent );
            })
        }

        private var dispatchFound:Function = function():void
        {
            var changeEvent:RecorderChangeEvent =
                new RecorderChangeEvent
                (
                    RecorderChangeEvent.CHANGE, 
                    RecorderChangeEvent.CODE_MIC_FOUND
                );
            MonsterDebugger.trace(this, 'dispatch found');
            
            nextTick(function():void
            {
                dispatchEvent( changeEvent );
            })
        }

        private function setupMic(mic:Microphone):void
        {
            var changeEvent:RecorderChangeEvent;

            if (mic == null){
                dispatchNotFound();
                return;
            }

            dispatchFound();

            mic.rate = Number(config['rate']);
            mic.gain = Number(config['gain']);
            mic.setSilenceLevel(Number(config['silence']));
            mic.encodeQuality = Number(config['quality']);
            mic.addEventListener(StatusEvent.STATUS, onMicStatus);

            if (mic.muted)
            {
                dispatchMuted();
            }
            else{
                dispatchUnmuted();
            }
        }

        private function clearMic(mic:Microphone):void
        {
            mic.removeEventListener(StatusEvent.STATUS, onMicStatus);
        }

        function Recorder(mic:Microphone, cfg:Object)
        {
            var changeEvent:RecorderChangeEvent;
            var me:Recorder = this;
            config = cfg;

            onMicStatus = function(evt:StatusEvent):void
            {
                MonsterDebugger.trace(dispatchMuted, 'mic status change');

                switch (evt.code) 
                {
                    case "Microphone.Unmuted":
                        dispatchUnmuted.call(me);
                        break;
                    case "Microphone.Muted":
                        dispatchMuted.call(me)
                        break;
                }
            };

            for(var key:String in defaultSetting)
            {
                if (!(key in config))
                {
                    config[key] = defaultSetting[key];
                }
            }

            // setup mic detection
            timer = new Timer(2000);

            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
            {
                var m:Microphone = Microphone.getMicrophone();

                if (m == _mic)
                {
                    return;
                }

                if (_mic != null){
                    clearMic(_mic);
                }

                _mic = m;

                setupMic(m);

            });

            setupMic(mic);

            _mic = mic;
        }

        public function start():Ticket
        {
            throw new Error('function is not implemented yet');
        }

        public function record():Ticket
        {
            throw new Error('function is not implemented yet');
        }

        public function stop():Ticket
        {
            throw new Error('function is not implemented yet');
        }

        public function dispose():void
        {
            
        }

        public function get microphone():Microphone
        {
            return _mic;
        }

        public function get result():Container
        {
            throw new Error('function is not implemented yet');
        }
    }
}