package test;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpEntity;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class HttpClientTest2 {

	public static String doPostWithJson(String url, String json) {
		CloseableHttpClient httpClient = null;
		CloseableHttpResponse httpResponse = null;
		// 创建 httpClient 实例
		httpClient = HttpClients.createDefault();

		// 创建 httpPost 远程连接实例
		HttpPost httpPost = new HttpPost(url);

		// 为 httpPost 设置配置
		RequestConfig requestConfig = RequestConfig.custom().setConnectTimeout(35000).setConnectionRequestTimeout(35000)
				.setSocketTimeout(35000).build();
		httpPost.setConfig(requestConfig);

		// 设置请求头
		httpPost.addHeader("Content-Type", "application/json");

		try {
			// 设置 json 请求体，并使用 httpClient 进行请求
			httpPost.setEntity(new StringEntity(json));
			httpResponse = httpClient.execute(httpPost);

			// 从响应对象中获取响应内容
			HttpEntity entity = httpResponse.getEntity();
			return EntityUtils.toString(entity);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			// 关闭资源，另外 httpResponse 已经在 try() 中关闭了资源了，所以不用担心它
			if (null != httpClient) {
				try {
					httpClient.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return "";
	}

	public static void main(String[] args) {
		String url = "http://128.128.100.2:8011/Request";
		String json = "{\"Name\":\"personListRequest\",\"TimeStamp\":1542594185,\"Session\":\"abcdefabcdef_1555559039\", \"Data\":{\"Action\":\"addPerson\",\"PersonType\":2,\"PersonInfo\":{\"PersonId\":\"%s\",\"PersonName\":\"%s\",\"PersonPhoto\":\"%s\"}}}";
		String personId = "122332223";
		String personName = "haha";
		String photoBase64 = getImageToBase64("E:\\httpserver\\xdj.jpg");
		json = String.format(json, new String[] { personId, personName, photoBase64 });

		String result = doPostWithJson(url, json);
		System.out.println(result);
	}

	public static String doPost(String url, String personName, String personId, String imagePath) {
		String json = "{\"Name\":\"personListRequest\",\"TimeStamp\":1542594185,\"Data\":{\"Action\":\"addPerson\",\"PersonType\":2,\"PersonInfo\":{\"PersonId\":\"%s\",\"PersonName\":\"%s\",\"PersonPhoto\":\"%s\"}}}";
		String photoBase64 = getImageToBase64(imagePath);
		json = String.format(json, new String[] { personId, personName, photoBase64 });
		String ret = doPostWithJson(url, json);
		System.out.println(ret);
		return ret.endsWith("Succeed.\"}") ? "成功" : "失败";
	}

	// 图片转化成base64字符串
	public static String getImageToBase64(String imgFile) {
		// imgFile = "C:/Users/Administrator/Desktop/12.png";// 待处理的图片
		InputStream in = null;
		byte[] data = null;
		// 读取图片字节数组
		try {
			in = new FileInputStream(imgFile);
			data = new byte[in.available()];
			in.read(data);
			in.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		// 对字节数组Base64编码
		return Base64.encodeBase64String(data); // 返回Base64编码过的字节数组字符串
	}
}
Demo Version, Only convert first 5 files at one time, Please buy now!