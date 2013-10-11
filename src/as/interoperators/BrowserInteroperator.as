package interoperators
{
    import flash.external.ExternalInterface;
    import flash.system.Security;

    import Playcorder;
    import interoperators.UniversalInteroperator;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

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

        protected override function init():Promise
        {
            var dfd:Deferred = new Deferred();

            if (!ExternalInterface.available || _init == true){
                dfd.resolve( null );
                return dfd.promise;
            }

            // get domain name from browser
            var curDomain:String = ExternalInterface.call((<![CDATA[
                function playcorderBuiltinGetDomain()
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

            dfd.resolve(super.init());

            _init = true;

            return dfd.promise;
        }

        public function BrowserInteroperator(adHlp:Playcorder)
        {
            super(adHlp);
        }
    }
}