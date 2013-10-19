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
            var me:Container = this;
            var dfd:Deferred = new Deferred();
            var ticket:GUIDTicket = new GUIDTicket(dfd.promise);

            if ( type == null ) 
            {
                type = "binary-string";
            }

            MonsterDebugger.trace( me, 'try to download data: ' + type );

            nextTick(function():void
            {
                var result:*;
                // use string as data carrier because:
                // http://stackoverflow.com/questions/7217015/how-much-ram-does-each-character-in-ecmascript-javascript-string-consume

                if ( data is ByteArray )
                {
                    MonsterDebugger.trace( me, 'data is byte array');

                    var ba:ByteArray = ByteArray(data);
                    var byte1:int;
                    var byte2:int;

                    if ( type == "binary-string" )
                    {
                        var tmp:String = '';
                        var verified:Boolean = true;
                        var cur:uint = 0;
                        try
                        {
                            ba.position = 0;

                            while( ba.bytesAvailable > 0 )
                            {
                                byte1 = ba.readByte();

                                if ( ba.bytesAvailable > 0 )
                                {
                                    byte2 = ba.readByte();
                                }
                                else
                                {
                                    byte2 = 0;
                                }

                                tmp += String.fromCharCode( ( (byte1 + 128) << 8 ) + (byte2 + 128) );
                            }

                            result = tmp;

                            ba.position = 0;
                            // go through again to verify the string
                            // just in case there is byte that cannot be stored in a utf-16 string
                            while( ba.bytesAvailable > 0 )
                            {
                                byte1 = ba.readByte();

                                if ( ba.bytesAvailable > 0 )
                                {
                                    byte2 = ba.readByte();
                                }
                                else
                                {
                                    byte2 = 0;
                                }

                                if (result.charCodeAt(cur) != ( (byte1 + 128) << 8 ) + (byte2 + 128))
                                {
                                    verified = false;
                                    MonsterDebugger.trace( me, '=== binary-string debug starts ===' );
                                    MonsterDebugger.trace( me, cur );
                                    MonsterDebugger.trace( me, result.charCodeAt(cur) );
                                    MonsterDebugger.trace( me, byte1 );
                                    MonsterDebugger.trace( me, byte2 );
                                    MonsterDebugger.trace( me, '===  binary-string debug ends  ===' );
                                    break;
                                }

                                cur++;
                            }
                            
                            MonsterDebugger.trace( me, 'got result' );
                            MonsterDebugger.trace( me, 'result is verified: ' + verified.toString() );
                            MonsterDebugger.trace( me, 'result length match: ' + ( result.length * 2 == ba.length ) + ' ' + result.length + ' ' + ba.length );
                        }
                        catch ( ex:Error )
                        {
                            MonsterDebugger.trace( me, 'fail to get result: ' + ex.toString() );

                            dfd.reject( ex.toString() );

                            return;
                        }

                        dfd.resolve( 
                        {
                            guid: ticket.guid,
                            data: result,
                            length: ba.length
                        });
                    }
                    else
                    {
                        dfd.reject("download type is not supported");
                    }

                }
                else 
                {
                    dfd.reject("data format is not supported");
                }
            });


            return ticket;
        }

        public function upload(url:String):Ticket
        {
            var dfd:Deferred = new Deferred();
            var ticket:GUIDTicket = new GUIDTicket(dfd.promise);

            // use string as data carrier because:
            // http://stackoverflow.com/questions/7217015/how-much-ram-does-each-character-in-ecmascript-javascript-string-consume

            return ticket;
        }
    }
}