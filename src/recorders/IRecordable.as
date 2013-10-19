package recorders
{
    import tickets.Ticket;
    import flash.media.Microphone;
    import data.containers.Container

    public interface IRecordable
    {
        function start():Ticket
        function record():Ticket
        function stop():Ticket
        function get microphone():Microphone
        function get result():Container
    }
}