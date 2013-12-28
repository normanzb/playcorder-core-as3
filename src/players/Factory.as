package players
{
    import factories.IFactory;
    import players.Player;
    import players.FilePlayer;

    public class Factory implements IFactory
    {
        public static var inst:Factory = new Factory();

        public function produce(config:Object):Object
        {
            var rType:String = String(config["type"]);
            var ret:Player;

            rType = rType.toLowerCase();

            switch(rType)
            {
                case 'path':
                case 'file':
                    ret = new FilePlayer(config);
                    break;
                case 'local':
                case 'byte':
                case 'bytearray':
                    ret = new LocalPlayer(config);
                    break;
                case 'auto':
                default:
                    ret = new AutoPlayer(config);
                    break;
            }

            return ret;
        }
        
    }
}