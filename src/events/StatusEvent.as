package events
{
    import com.codecatalyst.promise.Deferred;
    import com.codecatalyst.promise.Promise;
    import com.demonsters.debugger.MonsterDebugger;

    import flash.events.Event;
    
    public class StatusEvent extends Event
    {
        
        private var _promises:Vector.<Promise>;

        public var targetStatus:String;

        public function get promise():Promise
        {
            return this._promises[ this._promises.length - 1 ];
        }

        public function set promise(value:Promise):void
        {
            var prm:Promise;
            var lastPromise:Promise = this._promises[ this._promises.length - 1 ];

            MonsterDebugger.trace(this, 'add a new promise');

            value.then(function(result:*):void
            {
                MonsterDebugger.trace(this, 'newly added promise resolved');
            });

            prm = lastPromise
                .then(function(result:*):Promise
                {
                    MonsterDebugger.trace(this, 'previous promise resolved');
                    return value;
                })

            prm.then(function(result:*):void
            {
                MonsterDebugger.trace(this, 'newly created promise resolved');
            })

            this._promises.push(prm);
        }
        
        /**
         * 
         * @param type
         * @param time
         * 
         */     
        public function StatusEvent(type:String, targetStatus:String)
        {
            super(type, false, false);

            this.targetStatus = targetStatus;

            var dfd:Deferred = new Deferred();

            // create a resolved dfd as the head node of _defers
            dfd.resolve(null);

            this._promises = new Vector.<Promise>();

            this._promises.push(dfd.promise);
            
        }
    }
}