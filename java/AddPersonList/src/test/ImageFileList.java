package test;

import java.io.File;
import java.text.DecimalFormat;
import java.util.Scanner;

public class ImageFileList {

	public static void main(String[] args) {
		System.out.println("请输入图片文件夹位置");
		Scanner sc = new Scanner(System.in);
		String fileName = sc.nextLine();
		fileName = "D:\\0-DesktopData\\89033";
		File imageDirectory = new File(fileName);
		startFromSpecificPosition(imageDirectory, 80000);
	}

	/**
	 * 从特定位置进行导入
	 * 
	 * @param imageDirectory
	 * @param index          默认是从第 1 个开始
	 */
	public static void startFromSpecificPosition(File imageDirectory, int index) {
		int i = 1;
		DecimalFormat df = new DecimalFormat("0.000000");// 设置保留位数
		File[] files = imageDirectory.listFiles();
		for (File f : files) {
			if (i < index) {
				i++;
				continue;
			}
			String fileName = f.getName();
			String personName = fileName.split("_")[0];
			String personId = fileName.split("_")[1];
			String filePath = f.getAbsolutePath();
			String url = "http://128.128.100.2:8011/Request";
			String res = HttpClientTest2.doPost(url, personName, personId, filePath);
			System.out.println("正在上传第 " + i + " 张图片，上传结果：" + res + " 进度："+i+" / "+files.length+" （"+df.format((float)i*100/files.length)+"%）");
			i++;
		}
	}
}
Demo Version, Only convert first 5 files at one time, Please buy now!