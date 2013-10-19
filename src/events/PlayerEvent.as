package events
{
    import flash.events.Event;

    import guids.GUID;
    
    public class PlayerEvent extends Event
    {
        public static const STARTED:String = 'started';
        public static const STOPPED:String = 'stoppped';

        /**
         * 
         * @param type
         * @param time
         * 
         */
        function PlayerEvent(type:String)
        {
            super(type, false, false);
        }
    
    }
}