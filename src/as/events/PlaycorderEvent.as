package events
{
    import flash.events.Event;
    
    public class PlaycorderEvent extends Event
    {
        public static const FAIL_NO_MIC:String = 'NoMic';

        
        public function PlaycorderEvent(type:String)
        {
            super(type, false, false);
            
        }
    
    }
}