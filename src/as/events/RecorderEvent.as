package events
{
    import flash.events.Event;

    import guids.GUID;
    
    public class RecorderEvent extends Event
    {
        public static const CONNECTED:String = 'connected';
        public static const DISCONNECTED:String = 'disconnected';
        public static const STARTED:String = 'started';
        public static const STOPPED:String = 'stoppped';
        public static const ERROR:String = 'error';

        public var guid:GUID;
        /**
         * 
         * @param type
         * @param time
         * 
         */     
        function RecorderEvent(type:String, guid:GUID)
        {
            super(type, false, false);

            this.guid = guid;
            
        }
    
    }
}