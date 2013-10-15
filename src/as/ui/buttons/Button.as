package ui.buttons
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    
    public class Button
        extends Sprite
    {
        private var _text:String = '';
        private var _bgColor:uint = 0xFFF;
        private const WIDTH:uint = 80;
        private const HEIGHT:uint = 20;
        private var _txtText:TextField;

        private function draw():void
        {
            graphics.beginFill(_bgColor);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();

            _txtText.text = _text;

            _txtText.x = ( width - _txtText.width ) / 2;
            _txtText.y = ( height - _txtText.height ) / 2;

            addChild( _txtText );
        }

        private function setupText():void
        {
            _txtText = new TextField();

            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFFFFFF;
            format.size = 14;
            format.underline = false;
            _txtText.defaultTextFormat = format;
            _txtText.autoSize = TextFieldAutoSize.LEFT;
            _txtText.selectable = false;
        }

        public function Button()
        {
            buttonMode = true;
            mouseChildren = false;
            setupText();
            draw();
        }

        public function get text():String
        {
            return _text;
        }
        public function set text(value:String):void
        {
            _text = value;
            draw();
        }

        public function get bgColor():uint
        {
            return _bgColor;
        }

        public function set bgColor(value:uint):void
        {
            _bgColor = value;
            draw();
        }
    }
}