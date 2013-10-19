package
{

    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.media.Microphone;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    import events.PlaycorderEvent;
    import recorders.Recorder;
    import players.Player;
    import interoperators.Interoperator;

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

        private function onAddedToStage(event:Event):void
        {
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

            MonsterDebugger.trace(this, 'instantiated');

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

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