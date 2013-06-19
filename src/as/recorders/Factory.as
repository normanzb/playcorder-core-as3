package recorders
{
    import factories.IFactory;
    import recorders.Recorder;
    import recorders.ASRRTMPRecorder;
    import recorders.RTMPRecorder;
    import recorders.LocalRecorder;
    import flash.media.Microphone;

    public class Factory implements IFactory
    {
        public static var inst:Factory = new Factory();

        public const TYPE_RMTP:String = 'rtmp';
        public const TYPE_ASRRMTP:String = 'asrrtmp';
        public const TYPE_LOCAL:String = 'local';

        public function produce(config:Object):Object
        {
            var rType:String = String(config["type"]);
            var mic:Microphone = Microphone(config["microphone"]);
            var ret:Recorder;

            rType = rType.toLowerCase();

            switch(rType)
            {
                case TYPE_ASRRMTP:
                    ret = new ASRRTMPRecorder(mic, config);
                    break;
                case TYPE_RMTP:
                    ret = new RTMPRecorder(mic, config);
                    break;
                case TYPE_LOCAL:
                default:
                    ret = new LocalRecorder(mic, config);
                    break;
            }

            return ret;
        }
        
    }
}