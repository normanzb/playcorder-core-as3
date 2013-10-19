package events
{
    import guids.GUID;

    public class RecorderErrorEvent extends RecorderEvent
    {
        public static const CODE_CONNECTION_FAIL:String = 'connection.fail';

        public var code:String;

        function RecorderErrorEvent(type:String, guid:GUID, code:String)
        {
            super(type, guid);

            this.code = code;
        }
    }
}