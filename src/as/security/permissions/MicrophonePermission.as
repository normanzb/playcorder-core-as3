package security.permissions
{

    import flash.events.Event;
    import flash.events.StatusEvent;
    import flash.media.Microphone;
    import flash.net.SharedObject;
    import flash.system.Security;
    import flash.system.SecurityPanel;

    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.demonsters.debugger.MonsterDebugger;

    import helpers.StateMachine;
    import events.StatusEvent;
    import interoperators.Interoperator;
    import ui.panels.MicrophonePermissionPanel;

    public class MicrophonePermission 
        extends Permission
    {
        private var _mic:Microphone;
        private var _requested:Boolean = false;
        private var _requesting:Deferred;
        private var _uiMicPanel:MicrophonePermissionPanel;
        private var onMicStatus:Function;
        private var _stateMachine:StateMachine = new StateMachine(['idle', 'grant', 'granting', 'granted']);
        private var _waitingForUnmute:Boolean = false;
        private var _safeList:SharedObject;
        private var _curDomain:String;

        private const NAME_SHARED:String = '__playcorder_safe_domain_list';

        private function onStateIdle(event:events.StatusEvent):void
        {

        }

        private function onStateGrant(event:events.StatusEvent):void
        {
            var dfd:Deferred = new Deferred();

            // see if the mic is muted or not
            if ( _mic.muted ) 
            {
                // that means the user haven't grant the permission
                // show the standard permission request panel
                Security.showSettings(SecurityPanel.PRIVACY);

                _waitingForUnmute = true;

                onMicStatus = function(evt:flash.events.StatusEvent):void
                {
                    switch (evt.code) 
                    {
                        case "Microphone.Unmuted":
                            MonsterDebugger.trace(this, 'Permission: unmuted!');
                            dfd.resolve( null );
                            break;
                    }
                }

                // attach event to watch microphone changes
                _mic.addEventListener(
                    flash.events.StatusEvent.STATUS, 
                    onMicStatus
                );

                MonsterDebugger.trace(this, 'Permission: waiting for user unmute microphone');
            }
            else 
            {
                // that means the user probably already remembered the setting to SWF hosting domain
                // and hence we can have access to mic directly
                // but granted to swf hosting domain doesn't mean user would like any 3rd party to 
                // interact with their microphone through our API, so here we cover it
                
                // check if current website already in the 'safe list'
                var domains:Array = _safeList.data.safeDomains;

                if ( domains.indexOf(_curDomain) >= 0 )
                {
                    // well, we are safe, go ahead to turn on the microphone
                    MonsterDebugger.trace(this, 'Permission: domain is in safe list');
                    dfd.resolve( null )
                }
                else
                {
                    // unfortunately, this is a new domain, lets show the prompt
                    MonsterDebugger.trace(this, 'Permission: domain is NOT in safe list, waiting for approval');
                    _uiMicPanel = new MicrophonePermissionPanel()
                    _uiMicPanel.domain = _curDomain;
                    Playcorder.stage.addChild( _uiMicPanel );
                    _uiMicPanel.addEventListener( 
                        'allowed', 
                        function allowedHandler(evt:Event):void
                        {
                            dfd.resolve( null );
                            _uiMicPanel.removeEventListener('allowed', allowedHandler);
                        }
                    );
                    _uiMicPanel.addEventListener( 
                        'rejected', 
                        function rejectedHandler(evt:Event):void
                        {
                            dfd.reject( null );
                            _uiMicPanel.removeEventListener('rejected', rejectedHandler);
                        }
                    );
                }
            }

            event.promise = dfd.promise;
        }

        private function onStateGranting(event:events.StatusEvent):void
        {
            
        }

        private function onStateGranted(event:events.StatusEvent):void
        {
            if ( _waitingForUnmute )
            {
                // attach event to watch microphone changes
                _mic.removeEventListener(
                    flash.events.StatusEvent.STATUS, 
                    onMicStatus
                );
            }
            else
            {

            }

            // adding the website to local storage
            if ( _curDomain != "" )
            {
                _safeList.data.safeDomains.push( _curDomain );
            }
        }

        function MicrophonePermission( interop:Interoperator )
        {

            super( interop );

            try
            {
                _safeList = SharedObject.getLocal(NAME_SHARED, "/", false);
            }
            catch(ex:Error)
            {
                MonsterDebugger.trace(this, 'bad news, local storage does not available');
            }

            _curDomain = interoperator.data['domain'] || "";

            if ( _safeList.data.safeDomains == null ) 
            {
                _safeList.data.safeDomains = [];
            }

            _stateMachine.addEventListener('idle', onStateIdle);
            _stateMachine.addEventListener('grant', onStateGrant);
            _stateMachine.addEventListener('granting', onStateGranting);
            _stateMachine.addEventListener('granted', onStateGranted);

        }

        public override function request():Promise
        {
            var dfd:Deferred = new Deferred();

            // skip if already done
            if ( _requested ) 
            {
                dfd.resolve( null );
                return dfd.promise;
            }

            // if requesting in progress
            // resolve when it is done 
            if ( _requesting != null )
            {
                dfd.resolve( _requesting.promise );
                return dfd.promise;
            }

            if ( _mic == null ) 
            {
                _mic = Microphone.getMicrophone();
            }

            if ( _mic == null )
            {
                dfd.reject( "Microphone cannot be found." );
                return dfd.promise;
            }

            _requesting = dfd;

            var prm:Promise = _stateMachine.gotoStatus('granted');
            dfd.resolve(prm);

            return dfd.promise
                .then(function():void
                {
                    _requesting = null;
                    _requested = true;
                });
        }
        
    }
}