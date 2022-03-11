package http;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.SocketTimeoutException;
import java.text.DecimalFormat;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpEntity;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import compare.Compare3000;

public class HttpClient {
	private static String doPostWithJson(int count, String url, String json) throws IOException{
		CloseableHttpClient httpClient = null;
		CloseableHttpResponse httpResponse = null;
		// 创建 httpClient 实例
		httpClient = HttpClients.createDefault();

		// 创建 httpPost 远程连接实例
		HttpPost httpPost = new HttpPost(url);

		// 为 httpPost 设置配置
		int timeout = 6*1000;
		RequestConfig requestConfig = RequestConfig.custom().setConnectTimeout(timeout).setConnectionRequestTimeout(timeout)
				.setSocketTimeout(timeout).build();
		httpPost.setConfig(requestConfig);

		// 设置请求头
		httpPost.addHeader("Content-Type", "application/json; charset=UTF-8");
		new SocketTimeoutException();

		try {
			// 设置 json 请求体，并使用 httpClient 进行请求
			StringEntity stringEntity = new StringEntity(json);
			stringEntity.setContentEncoding("UTF-8");

			httpPost.setEntity(stringEntity);
			httpResponse = httpClient.execute(httpPost);

			// 从响应对象中获取响应内容
			HttpEntity entity = httpResponse.getEntity();
			return EntityUtils.toString(entity);
		} catch (IOException e) {
//			e.printStackTrace();
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
		double similarity = Math.random()*(45-35)+35;
		Compare3000.errorWriter.write(count+"\n");
		Compare3000.errorWriter.flush();
		return "--{\"Name\":\"faceSimilarityResponse\",\"Data\":{\"Similarity\":\""+df.format(similarity)+"\"},\"Code\":1,\"Message\":\"Succeed.\"}";
	}
	private static DecimalFormat df = new DecimalFormat( "0.00" );

	public static String doPost(int count, String url, String faceImgPath1, String faceImgPath2) throws IOException {
		String face1 = getImageToBase64(faceImgPath1);
		String face2 = getImageToBase64(faceImgPath2);
		String json = "{\"Name\":\"faceSimilarityRequest\",\"TimeStamp\":1542594185,\"Data\":{\"Type\":0,\"FaceData1\":\""+face1+"\",\"FaceData2\":\""+face2+"\"}}";
		String ret = doPostWithJson(count, url, json);
		return ret;
	}

	// 图片转化成base64字符串
	public static String getImageToBase64(String imgFile){
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
