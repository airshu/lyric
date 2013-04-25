package com.alonepig.util
{
	import flash.utils.ByteArray;

	/**
	 * KRC 歌词解析 
	 * @author alonepig
	 * 
	 */	
	public class KRCLyricParser
	{
		/*  歌词信息集合 */
		public var list:Array; 
		
		private var api:Object;
		private var krc:String;
		private var miarry:Array;
		private var split:String = "{|}";
		private var reg_tabo:RegExp;
		private var reg_line:RegExp;
		private var reg_word:RegExp;
		
		public function KRCLyricParser()
		{
			miarry = [64, 71, 97, 119, 94, 50, 116, 71, 81, 54, 49, 45, 206, 210, 110, 105];
			reg_tabo = /\[(ti|ar|al|by|offset|total):(.+)\]\s+/ig;
			reg_line = /(\[(\d+),(\d+)\])(.+)\s+/ig;
			reg_word = /<(\d+),(\d+),(\d+)>([^<]*)/ig;
		}
		
		public function parse(data:*):Array
		{
			var l:int = 0;
			var ba:ByteArray = data;
			var len:int = ba.length;
			var head:ByteArray = new ByteArray();
			head.writeBytes(ba, 0, 3);
			var tag:String = head.toString();
			if (tag != "krc")
			{
				trace("krc解析不正确");
			}
			var zip_byte:ByteArray = new ByteArray();
			zip_byte.writeBytes(ba, 4);
			zip_byte.position = 0;
			var j:int = zip_byte.length;
			var k:int = 0;
			while (k < j)
			{
				l = (k % 16);
				zip_byte[k] = int((zip_byte[k] ^ miarry[l]));
				k = (k + 1);
			};
			try {
				zip_byte.uncompress();
			} catch(e:Error) 
			{
				trace(e);
			};
			krc = zip_byte.toString();
			parseContent();
			return list;
		}
		
		private function parseContent():void
		{
			var line:String;
			var newLine:String;
			var lyric:String = krc;
			lyric = lyric + "\n";
			var arr:Array = lyric.match(reg_tabo);
			var taboArr:Array = [];
			for each (line in arr) 
			{
				newLine = line.replace(reg_tabo, setTabo);
				if (newLine)
				{
					taboArr.push( newLine );
				}
			}
			list = [];
			lyric.replace(reg_line, setLine);
		}
		
		private function setTabo():String
		{
			var _local2:String = arguments[1];
			var _local3:String = arguments[2];
			if (_local2 == "total")
			{
				_local2 = "duration";
				_local3 = formatTime(parseInt(_local3));
			} else 
			{
				_local3 = _local3.replace(/</g, "&lt;");
				_local3 = _local3.replace(/>/g, "&gt;");
				_local3 = _local3.replace(/"/g, "&quot;");
				_local3 = _local3.replace(/@/g, "&amp;");
			}
			return ((_local2 + "=\"") + _local3) + "\"";
		}
		
		private function setLine():String
		{
			var _local2:Number = parseInt(arguments[2]);
			var _local3:Number = parseInt(arguments[3]);
			var _local4:Number = (_local2 + _local3);
			var _local5:String = arguments[4];
			var _local6:String = _local5.replace(reg_word, parseTail);
			var _local7:Array = _local6.split(split);
			var _local8:String = "";
			var _local9:Array = [];
			var _local10:int;
			var lyricArr:Array = [];
			while (_local10 < (_local7.length - 1)) 
			{
				_local9.push(_local7[_local10]);
				lyricArr.push( _local7[(_local10 + 1)] );
				_local8 = (_local8 + _local7[(_local10 + 1)]);
				_local10 = (_local10 + 2);
			}
			var info:Object = new Object();
			info.startTimer = _local2;
			info.endTimer = _local4;
			info.timeArr = _local9;
			info.lyricArr = lyricArr;
			list.push( info );
			return "";
		}
		
		private function parseTail():String
		{
			var _local2:int = parseInt(arguments[2]);
			var _local3:String = arguments[4];
			return ((_local2 + split) + _local3) + split;
		}
		
		private function formatTime(num:Number, bool:Boolean=false):String{
			var _local6:String;
			var _local3:String = "";
			var _local4:Number = num / 1000;
			var _local5:int = int(_local4);
			_local3 = ((zero((_local5 / 60)) + ":") + zero((_local5 % 60)));
			if (bool)
			{
				_local6 = _local4.toString();
				_local3 = _local3 + _local6.substr(_local6.indexOf("."));
			}
			return _local3;
		}
		
		private function zero(num:Number):String{
			var str:String = String(num);
			if (str.length < 2)
			{
				str = "0" + str;
			}
			return str;
		}
	}
}