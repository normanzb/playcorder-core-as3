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

        protected override function externalInstanceLookup(id:Number):String
        {
            return (<![CDATA[
                function playcorderBuiltinFindHostObject(methodName, arg1, arg2)
                {
                    var id = <ID>;
                    var objs = document.getElementsByTagName('object');
                    var args = Array.prototype.slice.call(arguments, 1);
                    for(var l = objs.length;l--;)
                    {
                        var obj = objs[l];

                        if (!obj || !obj.getID || obj.getID() != id)
                        {
                            continue;
                        }

                        obj[methodName].apply(obj, args);
                        break;
                    }
                }
            ]]>).toString().replace(/\<ID\>/g, id);
        }

        public function BrowserInteroperator(adHlp:Playcorder)
        {
            super(adHlp);
        }
    }
}