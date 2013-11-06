package data.encoders
{
    public class MP3Encoder
        extends Encoder
    {
        [Embed(source="/Worker.Encoder.MP3.swf", mimeType="application/octet-stream")]
        private static var bytClsWorker:Class;

        public function MP3Encoder()
        {
            workerByteClass = bytClsWorker;
        }
    }
}