package ui;

import java.awt.*;

import javax.swing.*;

public class EasyPingUI extends JFrame {

	public JTextField startIP = new JTextField(12);
	public JTextField endIP = new JTextField(12);
	public JButton pingBtn = new JButton("Ping");
	public JLabel[] labels = new JLabel[256];

	public Color defaultColor = new Color(203, 203, 203);
	public Color redColor = new Color(255, 142, 119);
	public Color greenColor = new Color(85, 170, 127);

	public EasyPingUI() {
		JPanel topPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
		JLabel setIpRange = new JLabel("Set IP Range");
		JLabel divider = new JLabel("~ ~");
		topPanel.add(setIpRange);
		topPanel.add(startIP);
		topPanel.add(divider);
		topPanel.add(endIP);
		topPanel.add(pingBtn);

		JPanel centerPanel = new JPanel(new GridLayout(16, 16));
		for (int i = 0; i < 16 * 16; i++) {
			JLabel jlb = new JLabel(String.valueOf(i), JLabel.CENTER);
			jlb.setOpaque(true);
			jlb.setForeground(Color.black);
			jlb.setBackground(defaultColor);
			jlb.setBorder(BorderFactory.createMatteBorder(10, 5, 10, 5, centerPanel.getBackground()));
			centerPanel.add(jlb);
			labels[i] = jlb;
		}

		// 设置布局
		setLayout(new BorderLayout());
		add(topPanel, BorderLayout.NORTH);
		add(centerPanel, BorderLayout.CENTER);

		// 设置窗口的基本属性
		setTitle("EasyPing");
		setSize(600, 800);
		setResizable(false);
		setLocationRelativeTo(null);
		setVisible(true);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	}

	public static void main(String[] args) {
		new EasyPingUI();
	}
}
