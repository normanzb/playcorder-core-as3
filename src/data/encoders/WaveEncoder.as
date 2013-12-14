package data.encoders
{

    public class WaveEncoder
        extends Encoder
    {
        public function WaveEncoder()
        {
            workerBytes = Playcorder.inst.loaderInfo.bytes;
            targetFormat = 'wave';
        }
    }
}