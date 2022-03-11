package cn.lilnfh;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.NetworkInterface;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

/**
 * 
 * @author JVT202107009
 *
 */
public class HttpFaceinfoLogServer {

	private static void createHttpServer() {
		try {
			InetSocketAddress inetSocketAddress = new InetSocketAddress(9981);
			HttpServer httpServer = HttpServer.create(inetSocketAddress, 0);
			// 创建上下文监听，拦截包含 "/faceinfo" 的请求
			httpServer.createContext("/faceInfo", new TestHttpHandler());
			// 开启服务器
			httpServer.start();
			System.out.println("服务器已经开启.");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		createHttpServer();
	}
}

class TestHttpHandler implements HttpHandler {

	private static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	private static int i = 1;
	private static String _today = "";
	private BufferedWriter bw;

	@Override
	public void handle(HttpExchange exchange) throws IOException {
		// TODO Auto-generated method stub
		Date now = new Date();
		StringBuilder body = new StringBuilder();
		try (InputStreamReader reader = new InputStreamReader(exchange.getRequestBody(), "utf-8")) {
			char[] buffer = new char[256];
			int read;
			while ((read = reader.read(buffer)) != -1) {
				body.append(buffer, 0, read);
			}
		}

		String requestBodyStr = body.toString();

		String remoteDeviceIP = exchange.getRemoteAddress().getAddress().getHostAddress();

		String today = sdf.format(now);

		if ("".equals(_today)) {
			// 如果 _today 为空值（第一次执行），则新建一个 BufferedWriter
			bw = new BufferedWriter(new FileWriter(today + "-faceinfo.log", true));
		} else if (!today.equals(_today)) {
			// 如果 _today 与当前 today 不同（过了一天），则新建一个 BufferedWriter 并关闭旧的 BufferedWriter
			bw.close();
			bw = new BufferedWriter(new FileWriter(today + "-faceinfo.log", true));
			System.out.println("进行写入文件...");
		}
		
		writeLog(bw, requestBodyStr, today);
		
		// 每 20 条写入一次文件
		if (i%20 == 0)
			_today = "reopen_file_flag";
			

		System.out.println("接收到第 " + (i++) + " 条记录，来自 " + remoteDeviceIP + "，长度：" + requestBodyStr.length());

		String response = "response ok!";
		exchange.sendResponseHeaders(200, 0);
		OutputStream os = exchange.getResponseBody();
		os.write(response.getBytes("UTF-8"));
		os.close();
	}
	
	private void writeLog(BufferedWriter bw, String requestBodyStr, String today) throws IOException {
		bw.write(requestBodyStr);
		bw.newLine();
		bw.flush();
		_today = today;
	}

}
