package recorders
{
    // flash built in
    import flash.events.NetStatusEvent;
    import flash.media.Microphone;

    // 3rd party
    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    // self created
    import helpers.StateMachine;
    import events.StatusEvent;
    import recorders.Recorder;
    import connectors.IConnectable;
    import tickets.Ticket;

    public class ASRRTMPRecorder 
        extends RTMPRecorder 
    {

        private const defaultSetting:Object = 
        {
            asr :
            {
                context : ''
            },

            ids : 
            {
                student : 0,
                activity : 0
            }
        };
        
        protected override function getConnectionParams():Array
        {
            var asrContext:String;
            var studentId:Number;
            var activityId:Number;

            var ret:Array = super.getConnectionParams();

            asrContext = String(config['asr']['context']);
            studentId = Number(config['ids']['student']);
            activityId = Number(config['ids']['activity']);

            ret.push(asrContext, studentId, activityId);

            return ret;
        }

        function ASRRTMPRecorder(mic:Microphone, cfg:Object)
        {
            super(mic, cfg);

            for(var key:String in defaultSetting)
            {
                if (!(key in config))
                {
                    config[key] = defaultSetting[key];
                }
            }
        }
    }
}