package data.containers
{
    import flash.utils.ByteArray;
    import flash.media.Microphone;

    import tickets.GUIDTicket;
    import tickets.Ticket;
    import data.encoders.WaveEncoder;
    import recorders.Recorder;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;
    import com.demonsters.debugger.MonsterDebugger;

    public class RemoteFileContainer
        extends Container
    {
        public function RemoteFileContainer(rec:Recorder)
        {

        }
    }
}