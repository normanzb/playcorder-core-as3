package events
{
    import flash.events.Event;
    
    public class AudioHelperEvent extends Event
    {
        public static const FAIL_NO_MIC:String = 'NoMic';

        
        public function AudioHelperEvent(type:String)
        {
            super(type, false, false);
            
        }
    
    }
}