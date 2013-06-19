package recorders
{
    import tickets.Ticket;
    import flash.media.Microphone;

    public interface IRecordable
    {
        function start():Ticket
        function record():Ticket
        function stop():Ticket
        function get microphone():Microphone
    }
}