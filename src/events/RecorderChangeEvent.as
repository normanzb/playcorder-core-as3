package events
{
    import flash.events.Event;

    public class RecorderChangeEvent extends Event
    {
        public static const CHANGE:String = 'change';
        public static const CODE_MIC_NOT_FOUND:String = 'microphone.not_found';
        public static const CODE_MIC_FOUND:String = 'microphone.found';
        public static const CODE_MIC_MUTED:String = 'microphone.muted';
        public static const CODE_MIC_UNMUTED:String = 'microphone.unmuted';

        public var code:String;

        function RecorderChangeEvent(type:String, code:String)
        {
            super(type);

            this.code = code;
        }
    }
}