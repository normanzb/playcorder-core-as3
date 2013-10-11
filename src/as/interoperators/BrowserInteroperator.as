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
        private var _funcToGetExternalHost:String = '';
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

            return dfd.promise
                .then(function():void
                {
                    // create sub objects on external object and bridging calls,
                    // this is to make the API more intuitive and object oriented
                    var strStart:String = (<![CDATA[
                        function playcorderBuiltinSetupSubObjectsAndBridge(MEMBER_NAME)
                        {
                            var host = (
                    ]]>).toString();
                    var strEnd:String = (<![CDATA[
                            )();

                            for( var name in MEMBER_NAME ) 
                            (function(name)
                            {

                                var value = MEMBER_NAME[ name ];

                                if 
                                ( 
                                    !MEMBER_NAME.hasOwnProperty(name) || 
                                    // not a member method
                                    value.indexOf('_') < 0
                                )
                                {
                                    return;
                                }
                                
                                var parts = value.split('_');

                                if ( !(parts[0] in host) ) 
                                {
                                    host[ parts[0] ] = {};
                                }

                                if ( parts[1].indexOf('on') == 0 ) 
                                {
                                    host[ parts[0] ][ parts[1] ] = null;
                                    host[ value ] = function()
                                    {
                                        return host[ parts[0] ][ parts[1] ].apply(host, arguments);
                                    };
                                }
                                else
                                {
                                    host[ parts[0] ][ parts[1] ] = function()
                                    {
                                        return host[ value ].apply(host, arguments);
                                    };
                                }

                            })(name);
                        }
                    ]]>).toString();

                    ExternalInterface.call(
                        (strStart + _funcToGetExternalHost + strEnd).replace(/\<ID\>/g, _count), UniversalInteroperator.MEMBER_NAME
                    );
                });
        }

        protected override function getFuncToInvokeExternalHostMethod(id:Number):String
        {
            var start:String = (<![CDATA[
                function playcorderBuiltinInvokeHostMethod(methodName, arg1, arg2)
                {
                    var args = Array.prototype.slice.call(arguments, 1);
                    var host = (
            ]]>).toString();

            var end:String = (<![CDATA[
                    )();
                    host[methodName].apply(host, args);
                }
            ]]>).toString();

            return (start + _funcToGetExternalHost + end).replace(/\<ID\>/g, id);
        }

        public function BrowserInteroperator(adHlp:Playcorder)
        {
            // a javascript func that look up external host object
            _funcToGetExternalHost = (<![CDATA[
                function playcorderBuiltinFindHostObject()
                {
                    var STR_BUILTIIN_OBJ = '__playcorderBuiltinObject';
                    var global = window;
                    var id = <ID>;
                    var objs = document.getElementsByTagName('object');
                    var args = Array.prototype.slice.call(arguments, 1);
                    var cache;
                    var host;

                    if ( global[STR_BUILTIIN_OBJ] != null && global[STR_BUILTIIN_OBJ][id] != null ) 
                    {
                        return global[STR_BUILTIIN_OBJ][id];
                    }

                    for(var l = objs.length;l--;)
                    {
                        var obj = objs[l];

                        if (!obj || !obj.getID || obj.getID() != id)
                        {
                            continue;
                        }

                        host = obj;
                        break;
                    }

                    if ( !(STR_BUILTIIN_OBJ in global) ) {
                        global[STR_BUILTIIN_OBJ] = {};
                    }

                    cache = global[STR_BUILTIIN_OBJ];

                    return cache[id] = host;
                }
            ]]>).toString();
            
            super(adHlp);
        }
    }
}