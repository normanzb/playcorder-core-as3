package events
{
    import flash.events.Event;
    import workers.messages.Message;
    
    public class EncoderEvent extends Event
    {
        public static const DONE:String = 'done';
        public static const PROGRESS:String = 'progress';

        public var message:Message;

        /**
         * 
         * @param type
         * @param time
         * 
         */
        function EncoderEvent(type:String)
        {
            super(type, false, false);
        }
    
    }
}