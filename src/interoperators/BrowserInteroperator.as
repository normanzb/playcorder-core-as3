package interoperators
{
    import flash.external.ExternalInterface;
    import flash.system.Security;

    import Playcorder;
    import interoperators.UniversalInteroperator;
    import security.permissions.MicrophonePermission;

    import com.demonsters.debugger.MonsterDebugger;
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;

    public class BrowserInteroperator extends UniversalInteroperator
    {
        private var _init:Boolean = false;
        private var _funcToGetExternalHost:String = '';
        private var _micPrmsn:MicrophonePermission;

        protected override function init():Promise
        {
            var me:Interoperator = this;
            var dfd:Deferred = new Deferred();

            // allow all domain to talk
            Security.allowDomain("*");

            if (!ExternalInterface.available || _init == true){
                dfd.resolve( null );
                return dfd.promise;
            }

            // get domain name from browser
            var curDomain:String = ExternalInterface.call((<![CDATA[
                function playcorderBuiltinGetDomain()
                {
                    return location.hostname;
                }
            ]]>).toString());

            // save domain name 
            this.data['domain'] = curDomain;

            MonsterDebugger.trace(this, 'got domain name: ' + curDomain);

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

                            // mark as loaded
                            host['loaded'] = true;
                            // this method will be called after onready
                            host['onisready'] = function() 
                            {
                                // tell the user we are ready
                                host.isReady = true;
                            };

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

                                (function recursion(){
                                    
                                    var parent = this;
                                    var parts = Array.prototype.slice.call(arguments);
                                    var member;

                                    if ( !(parts[0] in parent) ) 
                                    {
                                        parent[ parts[0] ] = {};
                                    }

                                    member = parent[ parts[0] ];

                                    if ( parts.length > 2 ) {
                                        parts.shift();
                                        recursion.apply( member, parts );
                                    }
                                    else if ( parts[1].indexOf('on') == 0 ) 
                                    {
                                        member[ parts[1] ] = null;
                                        host[ value ] = function()
                                        {
                                            if ( typeof member[ parts[1] ] == 'function')
                                            {
                                                return member[ parts[1] ].apply(host, arguments);
                                            }

                                            return null;
                                        };
                                    }
                                    else
                                    {
                                        member[ parts[1] ] = function()
                                        {
                                            return host[ value ].apply(host, arguments);
                                        };
                                    }
                                }).apply(host, parts);

                            })(name);
                        }
                    ]]>).toString();

                    ExternalInterface.call(
                        (strStart + _funcToGetExternalHost + strEnd).replace(/\<ID\>/g, _guid), UniversalInteroperator.MEMBER_NAME
                    );
                })
                .then(function():Promise
                {
                    // try to get permission to access the mic
                    MonsterDebugger.trace(this, 'try to get permission to access the mic');

                    _micPrmsn = new MicrophonePermission( me );    

                    return _micPrmsn
                        .request()
                        .then(
                            function():void
                            {
                                disabled = false;
                                // TODO: expose events
                                MonsterDebugger.trace(this, 'Microphone permission granted');
                            }, 
                            function():void
                            {
                                disabled = true;
                                MonsterDebugger.trace(this, 'Microphone permission rejected');
                            }
                        );
                });
        }

        protected override function getFuncToInvokeExternalHostMethod(id:String):String
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
                    var id = '<ID>';
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

            // disable by default
            disabled = true;
        }
    }
}