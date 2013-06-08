package interoperators
{
    import flash.external.ExternalInterface;
    import flash.system.Security;

    import AudioHelper;
    import interoperators.UniversalInteroperator;

    import com.demonsters.debugger.MonsterDebugger;

    public class BrowserInteroperator extends UniversalInteroperator
    {
        private var _init:Boolean = false;
        private const DOMAINS:Array = [
            "ef.com",
            "ef.com.cn",
            "englishtown.com",
            "englishtown.com.cn",
            "englishtown.com.br",
            "englishtown.com.hk",
            "englishtown.co.jp",
            "englishtown.co.kr"
        ];

        protected override function init():void
        {

            if (!ExternalInterface.available || _init == true){
                return;
            }

            // get domain name from browser
            var curDomain:String = ExternalInterface.call((<![CDATA[
                function audioHelperBuiltinGetDomain()
                {
                    return location.hostname
                }
            ]]>).toString());

            MonsterDebugger.trace(this, 'got domain name: ' + curDomain);

            // only allow ef domains to talk
            if (
                curDomain != null && 

                new RegExp("(\\.|^)(" + 
                    DOMAINS.join('|').replace(/\./g, '\\.') + 
                    ")$").test(curDomain)

            )
            {
                MonsterDebugger.trace(this, 'domain name checking passed');
                Security.allowDomain(curDomain);
            }
            else
            {
                MonsterDebugger.trace(this, 'domain name checking failed');
            }

            super.init();

            _init = true;
        }

        public function BrowserInteroperator(adHlp:AudioHelper)
        {
            super(adHlp);
        }
    }
}