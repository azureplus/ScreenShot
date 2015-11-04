package
{
	import flash.events.Event;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	public class ClientUtil
	{
		public function ClientUtil()
		{
			super();
			Security.loadPolicyFile("xmlsocket://127.0.0.1:9099");
		}
		private static var instance:ClientUtil
		public static function getInstance():ClientUtil
		{
			instance ||= new ClientUtil();
			
			return instance;			
		}
		private var client:Socket;
		public function connect(port:int = 9999):void
		{
			client = new Socket();
			client.addEventListener(Event.CONNECT,onConnect);
			client.addEventListener(ProgressEvent.SOCKET_DATA,readData);
			client.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS,readData2);
			client.connect("127.0.0.1",port);
		}
		public var readDataCallBack:Function;
		private var data:ByteArray = new ByteArray();
		private var length:int = 0;
		private var pos:uint;
		private function readData(event:ProgressEvent):void
		{
			if(length == 0)
			{
				length = client.readUnsignedInt();
				data = new ByteArray();
				data.length = length;
			}
			var temp:ByteArray = new ByteArray();
			client.readBytes(data,pos);
			pos += event.bytesLoaded;
			if(pos-4 == length)
			{
				data.position = 0;				
				readData(data);
				length = 0;
				pos = 0;
			}
		}
		
		private function readData2(event:OutputProgressEvent):void
		{
			trace(event.bytesPending,event.bytesTotal);
		}
		private function onConnect(event:Event):void
		{
			trace("连接到客户端");
		}
}