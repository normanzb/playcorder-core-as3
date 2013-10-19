package players
{
    import tickets.Ticket;
    import flash.events.EventDispatcher;

    public class Player extends EventDispatcher
    {
        function Player(cfg:Object)
        {
            
        }

        public function start(source:*):Ticket
        {
            throw new Error('function is not implemented yet');
        }

        public function play(source:*):Ticket
        {
            throw new Error('function is not implemented yet');
        }

        public function stop():Ticket
        {
            throw new Error('function is not implemented yet');
        }

        public function dispose():void
        {
            
        }
    }
}