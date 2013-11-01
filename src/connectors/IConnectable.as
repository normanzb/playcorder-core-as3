package connectors
{
    import tickets.Ticket;

    public interface IConnectable
    {
        function connect(...args):Ticket
        function disconnect():Ticket
    }
}