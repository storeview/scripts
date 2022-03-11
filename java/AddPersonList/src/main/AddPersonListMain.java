package main;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import http.HttpClient;
import ui.AddPersonListUI;

public class AddPersonListMain {
	
	public static BufferedWriter errorWriter;
	
	private AddPersonListUI ui;

	public AddPersonListMain() {
		ui = new AddPersonListUI();
		ui.pingBtn.addActionListener((e) -> {
			pingIP();
		});
		ui.imageNumberBtn.addActionListener((e) -> {
			testImageNum();
		});
		ui.start.addActionListener((e) -> {
			startImport();
		});
		ui.stop.addActionListener((e) -> {
			stopImport();
		});
	}

	public static void main(String[] args) throws IOException {
		new AddPersonListMain();
	}

	private boolean checkIP() {
		String pattern = "((?:(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))$)";
		String ip = ui.ip.getText();
		return Pattern.matches(pattern, ip);
	}

	private Runtime runtime = Runtime.getRuntime();

	private void pingIP() {
		if (!checkIP()) {
			printLog("IP 格式错误");
			return;
		}
		// 每个 IP 只 ping 一次，并且超时时间设置成 60 毫秒
		String pingCommand = String.format("ping %s -n 1 -w 60", ui.ip.getText());
		try {
			Process p = runtime.exec(pingCommand);
			BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
			String line = null;
			boolean isOnline = true;
			while ((line = br.readLine()) != null) {
				if (line.contains("100%")) {
					isOnline = false;
					break;
				}
			}
			br.close();
			if (isOnline) {
				ui.pingResult.setText("在线");
				ui.pingResult.setForeground(Color.green);
			} else {
				ui.pingResult.setText("离线");
				ui.pingResult.setForeground(Color.gray);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private String jsonCompress() {
		String json = ui.json.getText();
		return json;
	}

	private void printLog(String msg) {
		new Thread(() -> {
			ui.log.append(msg);
			ui.log.append("\n");
			ui.log.setCaretPosition(ui.log.getDocument().getLength());
		}).start();
	}

	private boolean checkDirectoryPath() {
		return true;
	}

	private void testImageNum() {
		if (!checkDirectoryPath()) {
			printLog("文件夹地址不正确");
			return;
		}
		String imageDirectoryPath = ui.imagePath.getText();
		File imageDirectoryFile = new File(imageDirectoryPath);
		int i = 0;
		for (File f : imageDirectoryFile.listFiles()) {
			if (f.getName().endsWith(".jpg"))
				i++;
		}
		ui.imageNumberResult.setText("        " + i + "          ");
	}

	private int getStartIndex() {
		String startIndexStr = ui.startIndex.getText();
		return Integer.valueOf(startIndexStr.trim());
	}

	private void startImport() {
		startFromSpecificPosition(getStartIndex());
	}

	/**
	 * 从指定位置开始导入
	 * 
	 * @param index
	 */
	public void startFromSpecificPosition(int index) {
		String url = String.format("http://%s:%s/Request", new String[] { ui.ip.getText(), ui.port.getText() });
		File imageDirectory = new File(ui.imagePath.getText());
		List<File> files = null;
		//System.out.println(index);
		try {
			// 获取目录下的所有图片文件对象
			files = Files.list(Paths.get(ui.imagePath.getText())).map(Path::toFile).collect(Collectors.toList());

			// 设置指定数量的 文件对象 元组
			String[][] msgQueen = new String[files.size()][5];

			// 从 index 处开始导入
			for (int i = index-1; i < files.size(); i++) {
				File f = files.get(i);
				String fileName = f.getName();

				// 消息数组： 图片索引号、下发地址URL、人员名称、人员ID、人员图片地址
				String[] msg = new String[] { i + "", url, fileName.split("_")[0], fileName.split("_")[1],
						f.getAbsolutePath() };

				msgQueen[i] = msg;
			}
			
			String errorPath = ui.ip.getText() + "-error.csv";
			File errorFile = new File(errorPath);
			errorWriter = new BufferedWriter(new FileWriter(errorFile));
			errorWriter.write("错误码,图片路径");
			errorWriter.newLine();
			errorWriter.flush();

			// 新建一个线程进行导入操作
			ImportImage importImage = new ImportImage(msgQueen);
			importImage.start();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	DecimalFormat df = new DecimalFormat("0.000000");// 设置保留位数

	private class ImportImage extends Thread {
		private String[][] msgQueen;

		public ImportImage(String[][] msgQueen) {
			this.msgQueen = msgQueen;
		}

		public void run() {
			int totalSize = msgQueen.length;
			for (String[] m : msgQueen) {
				if (m[0] == null) continue;
				//System.out.println(Arrays.toString(m));
				int index = Integer.parseInt(m[0]) + 1;
				String res;
				try {
					res = HttpClient.doPost(m[1], m[2], index + "", m[4]);
					printLog("正在上传第 " + index + " 张图片，上传结果：" + res + " 进度：" + index + " / " + totalSize + " （"
							+ df.format((float) index * 100 / totalSize) + "%）");
					index++;
					Thread.sleep(500);
				} catch (IOException | InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}

	private void stopImport() {

	}
}
Demo Version, Only convert first 5 files at one time, Please buy now!