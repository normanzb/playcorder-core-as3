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
        private var handle:Function = function(evt:StatusEvent):void
        {
            var changeEvent:RecorderChangeEvent;

            switch (evt.code) 
            {
                case "Microphone.Unmuted":
                    changeEvent = 
                        new RecorderChangeEvent
                        (
                            RecorderChangeEvent.CHANGE, 
                            RecorderChangeEvent.CODE_MIC_UNMUTED
                        );
                    dispatchEvent( changeEvent );
                    break;
                case "Microphone.Muted":
                    changeEvent = 
                        new RecorderChangeEvent
                        (
                            RecorderChangeEvent.CHANGE, 
                            RecorderChangeEvent.CODE_MIC_MUTED
                        );
                    dispatchEvent( changeEvent );
                    break;
            }
        };

        private function setupMic(mic:Microphone):void
        {
            var changeEvent:RecorderChangeEvent;

            if (mic == null){
                return;
            }

            mic.rate = Number(config['rate']);
            mic.gain = Number(config['gain']);
            mic.setSilenceLevel(Number(config['silence']));
            mic.encodeQuality = Number(config['quality']);
            mic.addEventListener(StatusEvent.STATUS, handle);
        }

        private function clearMic(mic:Microphone):void
        {
            mic.removeEventListener(StatusEvent.STATUS, handle);
        }

        function Recorder(mic:Microphone, cfg:Object)
        {
            var changeEvent:RecorderChangeEvent;
            config = cfg;

            for(var key:String in defaultSetting)
            {
                if (!(key in config))
                {
                    config[key] = defaultSetting[key];
                }
            }

            timer = new Timer(2000);

            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
            {
                var m:Microphone = Microphone.getMicrophone();

                if (m == _mic)
                {
                    return;
                }

                _mic = m;

                setupMic(m);

                if (m == null)
                {
                    changeEvent = 
                        new RecorderChangeEvent
                        (
                            RecorderChangeEvent.CHANGE, 
                            RecorderChangeEvent.CODE_MIC_NOT_FOUND
                        );
                }
                else
                {
                    changeEvent = 
                        new RecorderChangeEvent
                        (
                            RecorderChangeEvent.CHANGE, 
                            RecorderChangeEvent.CODE_MIC_FOUND
                        );
                    
                }

                dispatchEvent( changeEvent );

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
    }
}