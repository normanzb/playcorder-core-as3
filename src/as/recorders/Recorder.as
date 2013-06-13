package recorders
{
    import tickets.Ticket;
    import flash.events.EventDispatcher;
    import flash.media.Microphone;

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

        function Recorder(mic:Microphone, cfg:Object)
        {
            config = cfg;

            for(var key:String in defaultSetting)
            {
                if (!(key in config))
                {
                    config[key] = defaultSetting[key];
                }
            }

            if (mic == null)
            {
                throw new Error('mic must not be null');
            }

            mic.rate = Number(config['rate']);
            mic.gain = Number(config['gain']);
            mic.setSilenceLevel(Number(config['silence']));
            mic.encodeQuality = Number(config['quality']);

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

        public function get activity():Number
        {
            return 0;
        }
    }
}