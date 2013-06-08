package connectors
{
    import tickets.Ticket;

    public interface IConnectable
    {
        function connect():Ticket
        function disconnect():Ticket
    }
}