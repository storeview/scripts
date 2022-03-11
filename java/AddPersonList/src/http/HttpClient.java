package http;

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
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import main.AddPersonListMain;

public class HttpClient {
	private static String regex = "\"Result\":([-0-9]+)\\}";
	private static Pattern pattern = Pattern.compile(regex, Pattern.MULTILINE);
	
	
	
	private static String doPostWithJson(String url, String json) {
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
		httpPost.addHeader("Content-Type", "application/json; charset=UTF-8");

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

	/**
	 * 执行 post 操作
	 * 
	 * @param url
	 * @param personName
	 * @param personId
	 * @param imagePath
	 * @return
	 * @throws IOException
	 */
	public static String doPost(String url, String personName, String personId, String imagePath) throws IOException {
		// 获得指定路径下的图片 Base64 编码值
		String photoBase64 = getImageToBase64(imagePath);

		// 组装 json 语句
		String json = "{\"Name\":\"personListRequest\",\"TimeStamp\":1542594185,\"Session\":\"abcdefabcdef_1555559039\", \"Data\":{\"Action\":\"addPerson\",\"PersonType\":2,\"PersonInfo\":{\"PersonId\":\""
				+ personId + "\",\"PersonName\":\"" + personName + "\",\"PersonPhoto\":\"" + photoBase64 + "\"}}}";

		// 执行请求，获取返回值
		String ret = doPostWithJson(url, json);
		
		

		//System.out.println(ret);
		String fail_or_not = ret.endsWith("Succeed.\"}") ? "成功" : "失败";

		// 如果失败了，则输入日志到文件
		if ("失败".equals(fail_or_not)) {
			Matcher matcher = pattern.matcher(ret);
			if(matcher.find()) {
				AddPersonListMain.errorWriter.write(matcher.group(1) + ",");
			}
			
			AddPersonListMain.errorWriter.write(imagePath);
			AddPersonListMain.errorWriter.newLine();
			AddPersonListMain.errorWriter.flush();
		}

		return fail_or_not;
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