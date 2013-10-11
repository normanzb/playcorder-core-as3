package interoperators
{
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import Playcorder;

    public class Interoperator
    {
        protected var playcorder:Playcorder;

        protected function init():Promise
        {
            var dfd:Deferred = new Deferred();

            dfd.resolve( null );

            return dfd.promise;
        }

        protected function onReady():void
        {

        }

        public function Interoperator(adHlp:Playcorder)
        {
            playcorder = adHlp;

            var prm:Promise = init();
            prm.then(function():void
            {
                onReady();
            });
        }
    }
}