package cn.lilnfh;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class ConfirmationDialog {

    public static String check(String title, String operateStr, String expectStr) {
        if (dialog == null) {
            createDialogUI(new JFrame());
        }
        if (title != null && !title.equals(""))
            dialog.setTitle(title);
        operateTextArea.setText(operateStr);
        expectTextArea.setText(expectStr);
        dialog.setVisible(true);
        return retMsg;
    }

    private static String retMsg = "none";
    private static JDialog dialog;
    private static JTextArea operateTextArea;
    private static JTextArea expectTextArea;

    private static void createDialogUI(JFrame frame) {
        dialog = new JDialog(frame, "结果确认", JDialog.ModalityType.DOCUMENT_MODAL);
        dialog.setLocationRelativeTo(frame);
        dialog.setSize(400, 520);
        dialog.setAlwaysOnTop(true);
        Container dialogContainer = dialog.getContentPane();
        dialogContainer.setLayout(new GridLayout(7, 1));

        dialogContainer.add(new JLabel("操作步骤"));
        operateTextArea = new JTextArea();
        operateTextArea.setEditable(false);
        dialogContainer.add(operateTextArea);

        dialogContainer.add(new JLabel("预期结果"));
        expectTextArea = new JTextArea();
        expectTextArea.setEditable(false);
        dialogContainer.add(expectTextArea);

        JPanel buttonPanel = new JPanel(new GridLayout(1, 2));
        JButton passBtn = new JButton("通过");
        JButton failBtn = new JButton("失败");
        buttonPanel.add(passBtn);
        buttonPanel.add(failBtn);
        dialogContainer.add(buttonPanel);

        dialogContainer.add(new JLabel("异常情况说明"));
        JTextArea exceptionTextArea = new JTextArea();
        dialogContainer.add(exceptionTextArea);

        passBtn.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                ConfirmationDialog.retMsg = "pass";
                dialog.setVisible(false);
            }
        });
        failBtn.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                ConfirmationDialog.retMsg = "fail" + "#" + exceptionTextArea.getText();
                exceptionTextArea.setText("");
                dialog.setVisible(false);
            }
        });
    }
}
