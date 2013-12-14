package
{

    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.media.Microphone;
    import flash.system.Worker;
    import flash.utils.ByteArray;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    import events.PlaycorderEvent;
    import recorders.Recorder;
    import players.Player;
    import interoperators.Interoperator;
    import workers.encoders.Base;
    import workers.encoders.MP3;
    import workers.encoders.Wave;

    [SWF(width="240", height="160", frameRate="24", backgroundColor="#FFFFFF")]
    public class Playcorder extends Sprite
    {
        public const NAME:String = 'Playcorder';

        public var recorder:Recorder;
        public var player:Player;
        public var interop:Interoperator;

        private var _recorderInited:Boolean = false;
        private var _playerInited:Boolean = false;
        private var _mic:Microphone;
        public static var stage:Stage;
        public static var inst:Playcorder;

        private function onAddedToStage(event:Event):void
        {
            inst = this;
            Playcorder.stage = this.stage;
            interop = Interoperator(interoperators.Factory.inst.produce(this));
        }

        private function getMicrophone():void
        {
            if (_mic == null)
            {
                _mic = Microphone.getMicrophone();
            }
            
        }

        public function Playcorder()
        {
            // Start the MonsterDebugger
            MonsterDebugger.initialize(this);

            if ( Worker.current.isPrimordial)
            {
                addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
                MonsterDebugger.trace(this, 'instantiated:primordial');
            }
            else
            {
                var workerEncoder:Base;
                var format:String = Worker.current.getSharedProperty('target.format') as String;

                MonsterDebugger.trace(this, 'target format: ' + format);

                if (format == 'mp3')
                {
                    workerEncoder = new MP3();
                }
                else
                {
                    workerEncoder = new Wave();
                }
                
                addChild( workerEncoder );
                MonsterDebugger.trace(this, 'instantiated:worker');
            }

        }

        public function init_recorder(config:Object):Boolean
        {
            var ret:Boolean = true;
            MonsterDebugger.trace(this, 'recorder initializing...');

            if (_mic == null)
            {
                // try to get microphone once
                getMicrophone();
            }

            if (_mic == null)
            {
                // TODO: start microphone change detection
                ret = false;
            }

            config["microphone"] = _mic;

            if (recorder != null)
            {
                recorder.dispose();
            }

            // create recorder and player according to configuration
            recorder = Recorder(recorders.Factory.inst.produce(config || {}));
            
            _recorderInited = true;

            return ret;
        }

        public function init_player(config:Object):Boolean
        {
            MonsterDebugger.trace(this, 'player initializing...');

            if (player != null)
            {
                player.dispose();
            }

            player = Player(players.Factory.inst.produce(config || {}));

            _playerInited = true;

            return true;
        }

        public function prepare():Boolean
        {
            getMicrophone();

            if (_mic != null)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}