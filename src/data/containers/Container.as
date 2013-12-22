package data.containers
{
    import flash.utils.ByteArray;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.codecatalyst.util.*;
    import com.demonsters.debugger.MonsterDebugger;

    import tickets.GUIDTicket;
    import tickets.Ticket;

    public class Container
    {
        protected var _type:String = '';
        public var data:*;

        protected function set type( value:String ):void
        {
            _type = value;
        }

        public function get type( ):String
        {
            return _type;
        }

        public function download(type:String):Ticket
        {
            throw "Not implemented";
        }

        public function upload(type:String, url:String, options:Object = null ):Ticket
        {
            var dfd:Deferred = new Deferred();
            var ticket:GUIDTicket = new GUIDTicket(dfd.promise);

            // use string as data carrier because:
            // http://stackoverflow.com/questions/7217015/how-much-ram-does-each-character-in-ecmascript-javascript-string-consume

            return ticket;
        }
    }
}