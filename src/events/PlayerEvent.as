package events
{
    import flash.events.Event;

    import guids.GUID;
    
    public class PlayerEvent extends Event
    {
        public static const STARTED:String = 'started';
        public static const STOPPED:String = 'stopped';
        public var guid:GUID;

        /**
         * 
         * @param type
         * @param time
         * 
         */
        function PlayerEvent(type:String, guid:GUID)
        {
            super(type, false, false);

            this.guid = guid;
        }
    
    }
}