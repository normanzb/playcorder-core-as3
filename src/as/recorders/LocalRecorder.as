package recorders
{
    // flash built in
    import flash.events.NetStatusEvent;
    import flash.media.Microphone;

    // 3rd party
    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    // self created
    import helpers.StateMachine;
    import events.StatusEvent;
    import recorders.Recorder;
    import connectors.IConnectable;
    import tickets.Ticket;

    public class LocalRecorder 
        extends Recorder 
    {
        
        function LocalRecorder(mic:Microphone, config:Object)
        {
            super(mic, config);
        }

        public override function start():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:Ticket = new Ticket(dfd.promise);

            return ret;
        }

        public override function record():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:Ticket = new Ticket(dfd.promise);

            return ret;
        }

        public override function stop():Ticket
        {
            var dfd:Deferred = new Deferred();
            var ret:Ticket = new Ticket(dfd.promise);

            return ret;
        }
    }
}