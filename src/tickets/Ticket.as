package tickets
{
    import com.codecatalyst.promise.Promise;

    public class Ticket
    {

        private var _promise:Promise;

        function Ticket(promise:Promise)
        {
            _promise =  promise;
        }

        public function get promise():Promise
        {
            return _promise;
        }
    }
}