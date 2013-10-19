package tickets
{
    import guids.GUID;
    import com.codecatalyst.promise.Promise;

    public class GUIDTicket extends Ticket
    {
        public var guid:GUID;

        function GUIDTicket(promise:Promise = null, guid:GUID = null)
        {
            this.guid = guid || GUID.create();

            super(promise);
        }
    }
}