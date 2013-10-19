package helpers
{
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.demonsters.debugger.MonsterDebugger;

    import events.StatusEvent;
    import flash.events.EventDispatcher;

    public class StateMachine extends EventDispatcher
    {
        private var _cur:Number = 0;
        private var _status:String;
        private var _inLoop:Deferred;
        private var _targetStatus:String;

        public var states:Array;

        private function onReset():void
        {
            MonsterDebugger.trace(this, 'state reset');

            _cur = 0;
            _status = states[_cur];
            _targetStatus = null;
            _inLoop = null;
        }

        private function looper():void
        {
            var newStatus:String;
            var evt:StatusEvent;
            var me:StateMachine = this;
            var value:String = this._targetStatus;

            MonsterDebugger.trace(me,  
                'check if we are going to next state');
            MonsterDebugger.trace(me,  
                'target state: ' + value + ', current state: ' + this._status);

            if ( this._status == value ) 
            {

                if ( this._inLoop != null ) 
                {

                    this._inLoop.resolve(null);

                    this._inLoop = null;
                }

                return;
            }

            if ( this._inLoop == null )
            {
                MonsterDebugger.trace(me, 'create a new _inLoop Deferred');

                this._inLoop = new Deferred();
            }

            this._cur++;

            if (this._cur >= this.states.length)
            {
                this._cur = 0;
            }

            newStatus = this.states[ this._cur ];

            evt = new StatusEvent( newStatus , value );

            MonsterDebugger.trace( me, 'Dispatching state event: ' + newStatus );

            this.dispatchEvent( evt );

            this._status = newStatus;

            MonsterDebugger.trace(me,  
                        'hook promise event');

            evt
                .promise
                .then(function():void
                {
                    MonsterDebugger.trace(me,  
                        'state handler executed, go ahead');

                    me.looper();
                },
                function(msg:String):void
                {
                    MonsterDebugger.trace(me,  
                        'state change failed due to reason: ' + msg);

                    if (_inLoop)
                    {
                        _inLoop.reject(msg);
                    }

                    _inLoop = null;
                });

            MonsterDebugger.trace(me,  
                        'hook promise event done');

        }

        public function StateMachine(states:Array)
        {
            this.states = states;

            for(var l:Number = this.states.length; l--;)
            {
                this.states[l] = this.states[l].toLowerCase();
            }

            _status = states[_cur];
        }

        public function gotoStatus(value:String):Promise
        {
            var me:StateMachine = this;
            var found:Boolean = false;
            var l:Number;

            MonsterDebugger.trace(this, 'goto status ' + value);

            // this means we are in process of something
            if ( this._inLoop != null )
            {
                MonsterDebugger.trace(this,  
                    'a status transition in progress ' + this._targetStatus);

                // then we should wait until it is done
                return this._inLoop
                    .promise
                    .then(function():Promise
                    {
                        return me.gotoStatus(value);
                    });

            }

            value = value.toLowerCase();

            for(l = this.states.length; l--;)
            {
                if (this.states[l] == value)
                {
                    found = true;
                    break;
                }
            }

            if (!found)
            {
                throw new Error('Status cannot be found: ' + value);
            }

            this._targetStatus = value;

            // step through
            this.looper();

            if (this._inLoop)
            {
                return this._inLoop.promise;
            }
            else
            {
                var dfd:Deferred = new Deferred();
                dfd.resolve(null);

                return dfd.promise;
            }

        }

        public function get status():String 
        {
            return this._status;
        }

        public function reset():Promise
        {
            var dfd:Deferred;

            MonsterDebugger.trace(this, 'try to state reset');

            if (_inLoop)
            {
                MonsterDebugger.trace(this, ' reset deferred');                
                dfd = _inLoop;
            }
            else
            {
                dfd = new Deferred();

                dfd.resolve(null);
            }

            return dfd
                .promise
                .then(function():void
                {
                    onReset();
                }, function():void
                {
                    onReset();
                });

        }


    }
}