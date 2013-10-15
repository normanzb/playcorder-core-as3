package ui.panels
{
    import ui.panels.Panel;
    import ui.buttons.Button;

    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.events.MouseEvent;
    import flash.events.Event;

    public class MicrophonePermissionPanel
        extends Panel
    {
        private var _bgColor:uint = 0xFFCC00;
        private var _txtCaption:TextField;
        private var _txtInfo:TextField;
        private var _btnAllow:Button;
        private var _btnReject:Button;
        private var _domain:String = '';
        private const WIDTH:uint = 240;
        private const PADDING_LEFT:uint = 15;

        private function setupCaption():void
        {
            _txtCaption = new TextField();

            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFFFFFF;
            format.size = 14;
            format.underline = false;
            _txtCaption.defaultTextFormat = format;
            _txtCaption.autoSize = TextFieldAutoSize.LEFT;
        }

        private function setupInfo():void
        {
            _txtInfo = new TextField();

            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0xFFFFFF;
            format.size = 12;
            format.underline = false;
            _txtInfo.defaultTextFormat = format;
            _txtInfo.multiline = true;
            _txtInfo.wordWrap = true;
            _txtInfo.width = WIDTH - PADDING_LEFT * 2;
        }

        private function setupAllow():void
        {
            _btnAllow = new Button();
            _btnAllow.text = 'Allow';
            _btnAllow.bgColor = 0xB21212;
        }

        private function setupReject():void
        {
            _btnReject = new Button();
            _btnReject.text = 'Reject';
            _btnReject.bgColor = 0x0971B2;
        }

        public function MicrophonePermissionPanel()
        {
            setupCaption();
            setupInfo();
            setupAllow();
            setupReject();

            // initial draw
            draw();

            // hooking events
            _btnAllow.addEventListener( 
                MouseEvent.CLICK, 
                function(event:MouseEvent):void
                {
                    var evt:Event = new Event('allowed', false, false);
                    dispatchEvent( evt );
                }
            );
            _btnReject.addEventListener( 
                MouseEvent.CLICK, 
                function(event:MouseEvent):void
                {
                    var evt:Event = new Event('rejected', false, false);
                    dispatchEvent( evt );
                }
            );
        }

        private function draw():void
        {

            graphics.beginFill(_bgColor);
            graphics.drawRect(0, 0, WIDTH, 160);
            graphics.endFill();

            _txtCaption.text = 'Privacy';
            _txtCaption.x = PADDING_LEFT;
            _txtCaption.y = 10;

            _txtInfo.text = 'Allow ' + _domain + ' to access your camera and microphone?';
            _txtInfo.x = PADDING_LEFT;
            _txtInfo.y = 30;

            _btnAllow.x = PADDING_LEFT;
            _btnAllow.y = 120;

            _btnReject.x = width - PADDING_LEFT - _btnReject.width;
            _btnReject.y = 120;

            addChild( _txtCaption );
            addChild( _txtInfo );
            addChild( _btnAllow );
            addChild( _btnReject );
        }

        public function set domain(value:String):void
        {
            _domain = value;
            draw();
        }

        public function get domain():String
        {
            return _domain;
        }
    }
}