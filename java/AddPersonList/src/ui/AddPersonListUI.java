package ui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridLayout;

import javax.swing.*;
import javax.swing.UIManager.LookAndFeelInfo;

public class AddPersonListUI extends JFrame {
	public JTextField ip;
	public JTextField port;
	public JButton pingBtn;
	public JLabel pingResult;
	public JTextArea json;
	public JTextArea log;
	public JTextField imagePath;
	public JButton imageNumberBtn;
	public JLabel imageNumberResult;
	public JButton start;
	public JButton stop;
	public JTextField startIndex;

	public AddPersonListUI() {
		try {
			for (LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
				if ("Nimbus".equals(info.getName())) {
					UIManager.setLookAndFeel(info.getName());
					break;
				}
			}
		} catch (Exception e) {

		}

		JPanel ipAndPortPanel = new JPanel();
		ipAndPortPanel.setLayout(new FlowLayout());
		JLabel ipLabel = new JLabel("设备IP");
		ip = new JTextField(20);
		JLabel portLabel = new JLabel("设备Port");
		port = new JTextField(20);
		pingBtn = new JButton("测试IP连通性");
		pingResult = new JLabel("          ");
		ipAndPortPanel.add(ipLabel);
		ipAndPortPanel.add(ip);
		ipAndPortPanel.add(portLabel);
		ipAndPortPanel.add(port);
		ipAndPortPanel.add(pingBtn);
		ipAndPortPanel.add(pingResult);

		JPanel jsonAndLogPanel = new JPanel();
		jsonAndLogPanel.setLayout(new GridLayout(1, 2));
		JPanel jsonPanel = new JPanel(new BorderLayout());
		JLabel jsonLabel = new JLabel("json字符串");
		json = new JTextArea();
		jsonPanel.add(jsonLabel, BorderLayout.NORTH);
		jsonPanel.add(json, BorderLayout.CENTER);
		JPanel logPanel = new JPanel(new BorderLayout());
		JLabel logLabel = new JLabel("日志");
		log = new JTextArea();
		log.setEditable(false);
		log.setLineWrap(true);
		JScrollPane jsp = new JScrollPane(log);
		logPanel.add(logLabel, BorderLayout.NORTH);
		logPanel.add(jsp, BorderLayout.CENTER);
		jsonPanel.setBorder(BorderFactory.createMatteBorder(15, 15, 15, 15, getForeground()));
		logPanel.setBorder(BorderFactory.createMatteBorder(15, 15, 15, 15, getForeground()));
		jsonAndLogPanel.add(jsonPanel);
		jsonAndLogPanel.add(logPanel);

		JPanel imageDirectoryPathPanel = new JPanel();
		imageDirectoryPathPanel.setLayout(new FlowLayout());
		JLabel imagePathLabel = new JLabel("图片文件夹地址");
		imagePath = new JTextField(20);
		imageNumberBtn = new JButton("测试图片数量");
		imageNumberResult = new JLabel("                  ");
		imageDirectoryPathPanel.add(imagePathLabel);
		imageDirectoryPathPanel.add(imagePath);
		imageDirectoryPathPanel.add(imageNumberBtn);
		imageDirectoryPathPanel.add(imageNumberResult);
		imageDirectoryPathPanel.add(imageNumberResult);

		start = new JButton("开始导入");
		 startIndex = new JTextField("    1    ");
		 stop = new JButton("停止导入");
		imageDirectoryPathPanel.add(start);
		imageDirectoryPathPanel.add(startIndex);
		imageDirectoryPathPanel.add(stop);

		this.setLayout(new BorderLayout());
		this.add(ipAndPortPanel, BorderLayout.NORTH);
		this.add(imageDirectoryPathPanel, BorderLayout.SOUTH);
		this.add(jsonAndLogPanel, BorderLayout.CENTER);

		this.setVisible(true);
		this.setSize(1000, 400);
		this.setLocationRelativeTo(null);
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setTitle("HTTP批量将人脸图片导入名单库");
	}

	public static void main(String[] args) {
		new AddPersonListUI();
	}
}