package interoperators
{
    import flash.external.ExternalInterface;

    import factories.IFactory;
    import interoperators.UniversalInteroperator;
    import interoperators.BrowserInteroperator;
    import Playcorder;

    public class Factory implements IFactory
    {

        public static var inst:Factory = new Factory();

        private const ENV_NONE:String = 'limbo';
        private const ENV_BROWSER:String = 'browser';

        public function produce(adHlp:Object):Object
        {
            var env:String = ENV_NONE;
            var playcorder:Playcorder = Playcorder(adHlp);

            if (ExternalInterface.available)
            {
                var typeOfWindow:String = ExternalInterface.call('function(){return typeof window.document}');

                if (typeOfWindow == 'object')
                {
                    env = ENV_BROWSER;
                }
            }

            var ret:Interoperator;

            // create interoperator according to the environment
            switch(env)
            {
                case ENV_BROWSER:
                    ret = new BrowserInteroperator(playcorder);
                    break;
                default:
                    ret = new UniversalInteroperator(playcorder);
                    break;
            }

            return ret;
        }
    }
}