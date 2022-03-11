package cn.lilnfh;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetSocketAddress;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;


/**
 * JMeter 自定义jar包
 * 自动化测试，输入一个状态值，确认设备当前刷脸状态是否正确
 * @author JVT202107009
 * 2022-3-03
 * 
 * v1.0.1 添加 ignore 参数，必要时候，可以忽略刷脸执行结果，直接返回 true
 * v1.0.2 删除 createHttpServer 中的局部变量 httpServer
 *
 */
public class VerifyStatus {
	/**
	 * 判断当前刷脸状态是否正确
	 * @param expect	预期状态：true（开门成功）/false（开门失败）/ignore（忽略本次执行结果）
	 * @return
	 */
	public static String expect(String expect) {
		// 如果 http 服务器不存在，则新建一个
		if (httpServer == null)
			createHttpServer();
		if (expect.equals(curVerifyStatus) || expect.equals("ignore"))
			return "pass";
		else
			return "fail";
	}

	private static HttpServer httpServer;
	private static String curVerifyStatus = "none";

	/**
	 * 创建一个 http 服务器，只创建一次
	 */
	private static void createHttpServer() {
		try {
			httpServer = HttpServer.create(new InetSocketAddress(8011), 0);
			// 创建上下文监听，拦截包含 "/faceinfo" 的请求
			httpServer.createContext("/faceinfo", new TestHttpHandler());
			// 开启服务器
			httpServer.start();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	
	static class TestHttpHandler implements HttpHandler {
		@Override
		public void handle(HttpExchange exchange) throws IOException {
			// 获取 requestBody 信息
			StringBuilder body = new StringBuilder();
			try (InputStreamReader reader = new InputStreamReader(exchange.getRequestBody(), "utf-8")) {
				char[] buffer = new char[256];
				int read;
				while ((read = reader.read(buffer)) != -1) {
					body.append(buffer, 0, read);
				}
			}

			// 对字符串进行处理，正则表达式求值
			VerifyStatus.curVerifyStatus = "true";
			if (body.toString().contains("\"VerifyStatus\":0"))
				curVerifyStatus = "false";

			// 返回响应消息的消息：200
			String response = "test message";
			exchange.sendResponseHeaders(200, 0);
			OutputStream os = exchange.getResponseBody();
			os.write(response.getBytes("UTF-8"));
			os.close();
		}
	}
}


