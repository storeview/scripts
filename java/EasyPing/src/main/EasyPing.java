package main;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusAdapter;
import java.awt.event.FocusEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.regex.Pattern;

import javax.swing.JLabel;

import ui.EasyPingUI;

public class EasyPing {

	private EasyPingUI ui;

	public EasyPing() {
		this.ui = new EasyPingUI();
		this.ui.startIP.setText("128.128.10.0");;
		this.ui.pingBtn.addActionListener((e) -> {
			if (setEndIP())
				startPing();
		});
		this.ui.endIP.addFocusListener(new FocusAdapter() {
			public void focusGained(FocusEvent e) {
				setEndIP();
			}
		});
	}

	/**
	 * 检查输入的 IP 是否正确 - 如果正确，则设置 endIP - 如果不正确，则提示重新输入
	 */
	private boolean setEndIP() {
		String startIP = this.ui.startIP.getText();
		String pattern = "((?:(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))\\.){3}(?:25[0-5]|2[0-4]\\d|((1\\d{2})|([1-9]?\\d)))$)";
		boolean result = Pattern.matches(pattern, startIP);

		if (result) {
			int lastIndex = startIP.lastIndexOf('.');
			String endIP = startIP.substring(0, lastIndex + 1) + "255";
			this.ui.endIP.setText(endIP);
			return true;
		} else {
			System.out.println("IP 地址错误");
			return false;
		}
	}

	/**
	 * 准备线程，开始准备 ping
	 */
	private void startPing() {
		this.resetUI();
		String startIPText = this.ui.startIP.getText();
		String[] startIP = startIPText.split("\\.");
		String[] endIP = this.ui.endIP.getText().split("\\.");

		int lastIndex = startIPText.lastIndexOf('.');
		String tmpIP = startIPText.substring(0, lastIndex + 1);

		Thread[] threadList = new Thread[256];
		for (int i = Integer.valueOf(startIP[3]); i <= Integer.valueOf(endIP[3]); i++) {
			threadList[i] = new Thread(new GetPingResult(tmpIP + String.valueOf(i)));
		}

		for (Thread t : threadList) {
			if (t != null) {
				t.setDaemon(true);
				t.start();
			}
		}
	}

	private Runtime runtime = Runtime.getRuntime();
	/**
	 * 多线程进行 Ping 操作，并且及时将结果进行返回
	 * 
	 * 注意：ping 的瞬间的鼠标卡顿问题，应该是多线程更新 swing UI 造成的
	 */
	class GetPingResult implements Runnable {
		private String ip;

		public GetPingResult(String ip) {
			this.ip = ip;
		}

		public void run() {
			// 每个 IP 只 ping 一次，并且超时时间设置成 60 毫秒
			String pingCommand = String.format("ping %s -n 1 -w 60", ip);
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
				if (isOnline)
					EasyPing.this.setUI(true, ip);
				else
					EasyPing.this.setUI(false, ip);

			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * 根据 ping 的结果设置窗口的颜色
	 * 
	 * @param result 连通测试的结果
	 * @param ip     每次使用的 IP 地址
	 */
	private void setUI(boolean result, String ip) {
		int index = Integer.valueOf(ip.split("\\.")[3]);
		if (result)
			this.ui.labels[index].setBackground(this.ui.greenColor);
		else
			this.ui.labels[index].setBackground(this.ui.redColor);
	}

	/**
	 * 重设所有 label 的颜色为灰色
	 */
	private void resetUI() {
		for (JLabel label : this.ui.labels) {
			label.setBackground(this.ui.defaultColor);
		}
	}

	public static void main(String[] args) {
		EasyPing easyPing = new EasyPing();
	}
}
