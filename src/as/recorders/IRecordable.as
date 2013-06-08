package recorders
{
    import tickets.Ticket;

    public interface IRecordable
    {
        function start():Ticket
        function record():Ticket
        function stop():Ticket
        function get activity():Number
    }
}