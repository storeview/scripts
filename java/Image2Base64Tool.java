package tool;

import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.Scanner;

import org.apache.commons.codec.binary.Base64;


import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
    图片转 Base64 工具（命令行）
 */
public class Image2Base64Tool {

    /**
        主函数
     */
	public static void main(String[] args) throws InterruptedException {
		while(1==1) {
			// 从控制台输入『获取』图片文件路径
	        Scanner sc = new Scanner(System.in);
			System.out.println("Please drag a [ Image File ] into this windows(or enter you iamge file path):");
			String imagePath = sc.nextLine();
	        
	        // 使用正则表达式获取到文件名
	        String pattern = "^(.*)\\\\([^\\\\]+)\\.[a-z]+$";
	        Pattern p = Pattern.compile(pattern);
	        Matcher m = p.matcher(imagePath);
	        String filename = "imageBase64.txt";
	        while(m.find()){
	            filename = m.group(2);
	        }

	        // 图片转换为 Base64 ，保存为本地文件并复制到剪贴板中
	        String base64Str = getImageToBase64(imagePath);
			saveStringFile(base64Str, filename);
			save2Clipboard(base64Str);
			
			System.out.println("-\n-\n-\n");
		}
	}

	/**
     * 保存字符串到剪贴板中
	 * @param str
	 */
	private static void save2Clipboard(String str) {
		StringSelection ss = new StringSelection(str);
		Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
		clipboard.setContents(ss, ss);
		System.out.println("----------------");
		System.out.println("the content is already in your Clipboard");
		System.out.println("You can just PASTE it!");
	}

	/**
	 * 保存字符串到文件中 
	 * @param base64Str
	 */
	private static void saveStringFile(String base64Str, String filename) {
		try {
			String filePath = System.getProperty("user.dir") + "/" + filename  +".txt";
			BufferedWriter bw = new BufferedWriter(new FileWriter(filePath));
			bw.write(base64Str);
			bw.flush();
			bw.close();
			System.out.println("Complete!");
			System.out.println("File is generate in " + System.getProperty("user.dir"));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 图片转 Base64 编码 
	 * @param imgFile
	 * @return
	 */
	private static String getImageToBase64(String imgFilePath) {
		InputStream in = null;
		byte[] data = null;
		// 读取图片字节数组
		try {
			in = new FileInputStream(imgFilePath);
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
