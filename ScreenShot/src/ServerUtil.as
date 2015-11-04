package
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.events.OutputProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import spark.components.TextArea;

	public class ServerUtil
	{
		public function ServerUtil()
		{
				
		}		
		import flash.events.ServerSocketConnectEvent;
		import flash.net.ServerSocket;
		import flash.net.Socket;		
		private var serverSocket:ServerSocket;
		private var localIP:String="127.0.0.1";
		private var policyPort:int=9099;
		private var serverPort:int=9999;
		private var server:ServerSocket;
		private var clientSocket:Socket;
		private var sending:Boolean = false;
		private var log:TextArea;
		public function init(log:TextArea,policyPort:int=9099,serverPort:int=9999):void
		{
			this.log = log;
			this.policyPort = policyPort;
			this.serverPort = serverPort;
			initPolicyPort();
			initServerSocket();
		}
		private function initPolicyPort():void
		{
			serverSocket = new ServerSocket();
			serverSocket.bind(policyPort,localIP);
			serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onPolicyConnect );
			serverSocket.listen();
		}
		protected function onPolicyConnect(event:ServerSocketConnectEvent):void
		{
			var tmpsocket:Socket=event.socket;
			var xml:XML =<cross-domain-policy> 
				<site-control permitted-cross-domain-policies="all"/> 
				<allow-access-from domain="*" to-ports="*"/>
				</cross-domain-policy>
			tmpsocket.writeUTFBytes(xml.toString());
			tmpsocket.flush();
			trace("发送策略文件到:"+xml.toString()+tmpsocket.remoteAddress+":"+tmpsocket.remotePort)
			tmpsocket.close();
		}
		protected function initServerSocket():void
		{
			server = new ServerSocket();
			server.addEventListener(ServerSocketConnectEvent.CONNECT,onClientConnect);
			server.bind(9999);
			server.listen();
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER,sendData);
			timer.start();
		}
		private function sendData(event:TimerEvent):void
		{
			var obj:Object = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT,ClipboardTransferMode.ORIGINAL_ONLY);
			if(obj && !sending && clientSocket)
			{
				sending = true;
				var  bitmapData:BitmapData = BitmapData(obj);
				var data:ByteArray = bitmapData.encode(bitmapData.rect,new JPEGEncoderOptions(85));
				trace(data.length);
				log.text += "\n"+clientSocket.remoteAddress+","+clientSocket.remotePort+","+data.length;
				clientSocket.writeUnsignedInt(data.length);
				clientSocket.writeBytes(data);
				clientSocket.flush(); 
				Clipboard.generalClipboard.clear();			
				sending = false;
			}
		}
		private function onClientConnect(event:ServerSocketConnectEvent):void
		{
			clientSocket = event.socket;
			trace("接收到远程连接端口地址："+event.socket.remoteAddress,event.socket.remotePort);
			clientSocket.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS,function(event:OutputProgressEvent):void
			{
				trace(event.bytesTotal,event.bytesTotal);
				
			},false,0,true);
		}
	}
}