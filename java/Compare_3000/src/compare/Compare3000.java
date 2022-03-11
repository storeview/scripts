package compare;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Scanner;

import http.HttpClient;

/**
 * 借助 HTTP 接口，批量进行人脸图片相似度比对 v2 优化代码，增加程序中断可以从中断位置继续导入的功能 At 2021-10-28 09:08:19
 * 
 * @author JVT202107009
 *
 */
public class Compare3000 {
	private static String ip = "192.168.1.88";
	public static BufferedWriter errorWriter;

	public static void main(String[] args) throws IOException, InterruptedException {
		// 读取用户输入的 IP 地址
		System.out.println("Please input the IP:\n");
		Scanner sc = new Scanner(System.in);
		ip = sc.nextLine();
		System.out.println("\n--------OK---------\n");

		// 读取图片目录下的三千张图片
		String imgPath = "D:\\Compare3000\\imgs";
		File imgDir = new File(imgPath);
		File[] imgFiles = new File[3000];
		for (int i = 0; i < 3000; i++) {
			imgFiles[i] = new File(imgDir + "\\" + (i + 1) + ".jpg");
		}

		// 第 1 个人和 2-101 个人比较
		// 第 2 个人和 3-102 个人比较
		// ...
		// ...
		// 第2999个人和 3000-99

		// 结果日志
		String logPath = "D:\\Compare3000\\Result.csv";
		File logFile = new File(logPath);
		BufferedWriter bw = null;

		String errorPath = "D:\\Compare3000\\Error.txt";
		File errorFile = new File(errorPath);
		errorWriter = new BufferedWriter(new FileWriter(errorFile));

		// 当前是第几条数据，默认值：0
		int curCount = 0;
		// 下一个【需要和后面100个人进行比较】的人，默认值：1
		int curCompPerson = 1;

		// 如果日志文件已经存在，则读取日志的最后一条记录
		if (logFile.exists()) {
			System.out.println("文件已经存在（继续写入数据）...");

			// 提取最后一行数据到各个变量中
			String[] lineSplits = getTxtFileLastLine(logFile).split(",");
			curCount = Integer.parseInt(lineSplits[0]);
			curCompPerson = Integer.parseInt(lineSplits[1]);
			int curBeCompPerson = Integer.parseInt(lineSplits[2]);

			// 把当前比较人，还没有比完的部分比完
			bw = new BufferedWriter(new FileWriter(logFile, true));
			for (int j = curBeCompPerson - curCompPerson + 1; j <= 100; j++) {
				doCompare(++curCount, curCompPerson - 1, j, imgFiles, bw);
			}
			curCompPerson += 1;

		} else {
			// 否则就写入第一行的标题数据
			bw = new BufferedWriter(new FileWriter(logFile, true));
			bw.write("序号,比较人,被比较人,相似度\n");
		}

		// 比较3000次，每次比较100个人，一共30万次
		for (int i = curCompPerson - 1; i < 3000; i++) {
			for (int j = 1; j <= 100; j++) {
				doCompare(++curCount, i, j, imgFiles, bw);
			}
		}

		// 关闭文件
		bw.close();
		errorWriter.close();

		// 所有数据产生完成，可以关闭窗口了
		System.out.println("\n-------->OK<---------\n");
		sc.nextLine();
	}

	/**
	 * 进行一次人脸图片的比较，输出图片比较结果，并写入到csv文件中
	 * 
	 * @param count    比较次数
	 * @param i        比较人的图片索引
	 * @param j        被比较人的图片索引
	 * @param imgFiles 图片文件列表
	 * @param bw       有缓存的写入
	 * @throws IOException
	 */
	private static void doCompare(int count, int i, int j, File[] imgFiles, BufferedWriter bw) throws IOException {
		int index = (i + j) % 3000;

		System.out.print(count + "," + i + "," + j + "," + index);

		String ret = "";
		// 如果最后的相似度是 100，说明此次获取到了返回值，但是没有获取到【相似度】
		String similarity = "100";
		while (ret.equals("")) {
			// 进行http请求
			ret = HttpClient.doPost(count, "http://" + ip + ":8011/Request", imgFiles[i].getAbsolutePath(),
					imgFiles[index].getAbsolutePath());
			// 只要返回值不为空，就终止外层的循环
			if (!ret.equals("")) {
				// 输出日志
				System.out.println(ret);

				if (ret.split("Similarity\":\"").length > 1) {
					String split1 = ret.split("Similarity\":\"")[1];
					if (split1.split("\"}").length > 0) {
						similarity = split1.split("\"}")[0];
					}
				}
				break;
			}

		}

		String strLine = "" + count + "," + (i + 1) + "," + (index + 1) + "," + similarity + "\n";

		bw.write(strLine);
		bw.flush();
	}

	/**
	 * 获取文本文件最后一行数据
	 * 
	 * @return
	 * @throws IOException
	 */
	private static String getTxtFileLastLine(File txtFile) throws IOException {
		BufferedReader br = new BufferedReader(new FileReader(txtFile));
		String line = "";
		String lastLine = "";
		while (true) {
			line = br.readLine();
			if (line == null || line.equals(""))
				break;
			lastLine = line;
		}
		return lastLine;
	}
}
