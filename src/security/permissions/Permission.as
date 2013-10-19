package security.permissions
{
    import interoperators.Interoperator;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    public class Permission 
    {
        protected var interoperator:Interoperator;

        function Permission(interoperator:Interoperator)
        {
            this.interoperator = interoperator;
        }

        public function request():Promise
        {
            var dfd:Deferred = new Deferred();

            dfd.resolve( null );

            return dfd.promise;
        }

    }
}