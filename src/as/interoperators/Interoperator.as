package interoperators
{
    import AudioHelper;

    public class Interoperator
    {
        protected var audioHelper:AudioHelper;

        protected function init():void
        {

        }

        public function Interoperator(adHlp:AudioHelper)
        {
            audioHelper = adHlp;

            init();
        }
    }
}