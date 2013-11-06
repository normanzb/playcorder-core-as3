package data.encoders
{

    public class WaveEncoder
        extends Encoder
    {
        // ------- Embed the background worker swf as a ByteArray -------
        [Embed(source="/Worker.Encoder.Wave.swf", mimeType="application/octet-stream")]
        private static var bytClsWorker:Class;

        public function WaveEncoder()
        {
            workerByteClass = bytClsWorker;
        }
    }
}