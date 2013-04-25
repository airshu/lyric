package
{
	import com.alonepig.util.FileUtil;
	import com.alonepig.util.KRCLyricParser;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	
	public class LyricTool extends Sprite
	{
		
		private var fileUtil:FileUtil;
		
		public function LyricTool()
		{
			fileUtil = FileUtil.getInstance();
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}

		private function onAddToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			init();
		}
		
		public function init():void
		{
			fileUtil.loadBindaryFile( "xx.krc", lyricHandler );
		}

		private function lyricHandler(data:*):void
		{
			parseKRC( data );
		}

		/**
		 * 解析 KRC
		 * @param data data将歌词文件以字节数组的形式加载  
		 */		
		public function parseKRC(data:*):void
		{
			var parser:KRCLyricParser = new KRCLyricParser();
			var lyricDatas:Array = parser.parse(data);
		}
		
	
		
	}
}