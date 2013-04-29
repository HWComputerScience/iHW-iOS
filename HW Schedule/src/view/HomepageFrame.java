package view;

import java.awt.*;
import javax.swing.*;

public class HomepageFrame extends JFrame {
	private static final long serialVersionUID = -7222309803012419702L;

	public HomepageFrame() {
		Container contentPane = this.getContentPane();
		contentPane.setLayout(new BorderLayout());
		contentPane.setBackground(new Color(235, 229, 207));
		JLabel title = new JLabel("HW Schedule");
		title.setFont(new Font("Georgia", 0, 28));
		title.setBackground(new Color(153,0,0));
		title.setForeground(Color.WHITE);
		title.setOpaque(true);
		title.setHorizontalAlignment(SwingConstants.CENTER);
		contentPane.add(title, BorderLayout.NORTH);
		this.setSize(new Dimension(250,400));
		this.setResizable(false);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		this.validate();
	}
}
