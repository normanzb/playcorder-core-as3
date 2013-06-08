package recorders
{
    import factories.IFactory;
    import recorders.Recorder;
    import recorders.ASRRMTPRecorder;
    import recorders.RMTPRecorder;
    import recorders.LocalRecorder;
    import flash.media.Microphone;

    public class Factory implements IFactory
    {
        public static var inst:Factory = new Factory();

        public const TYPE_RMTP:String = 'rmtp';
        public const TYPE_ASRRMTP:String = 'asrrmtp';
        public const TYPE_LOCAL:String = 'local';

        public function produce(config:Object):Object
        {
            var rType:String = String(config["type"]);
            var mic:Microphone = Microphone(config["microphone"]);
            var ret:Recorder;

            if (mic == null)
            {
                throw new Error('mic must not be null.')
            }

            rType = rType.toLowerCase();

            switch(rType)
            {
                case TYPE_ASRRMTP:
                    ret = new ASRRMTPRecorder(mic, config);
                    break;
                case TYPE_RMTP:
                    ret = new RMTPRecorder(mic, config);
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