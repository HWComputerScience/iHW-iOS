package view;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.*;

public class HomepageFrame extends JFrame implements ActionListener {
	private static final long serialVersionUID = -7222309803012419702L;
	
	private ScheduleViewDelegate delegate;

	public HomepageFrame() {
		Container contentPane = this.getContentPane();
		contentPane.setLayout(new BorderLayout());
		contentPane.setBackground(new Color(235, 229, 207));
		JLabel title = new JLabel("HW Schedule"); // {
			title.setFont(new Font("Georgia", 0, 28));
			title.setBackground(new Color(153,0,0));
			title.setForeground(Color.WHITE);
			title.setOpaque(true);
			title.setHorizontalAlignment(SwingConstants.CENTER);
	//  }
		contentPane.add(title, BorderLayout.NORTH);
		JPanel buttonPanel = new JPanel(); // {
			buttonPanel.setLayout(new GridLayout(2,1));
	//  }
		contentPane.add(buttonPanel, BorderLayout.CENTER);
		this.setSize(new Dimension(250,400));
		this.setResizable(false);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		this.validate();
	}
	
	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }
	
	public void actionPerformed(ActionEvent evt) {
		if (delegate==null) return;
		if (((JButton)evt.getSource()).getText().equals("Edit Courses")) {
			delegate.showCourseEditor();
		} else if (((JButton)evt.getSource()).getText().equals("Edit Courses")) {
			delegate.showSchedule();
		}
	}
}
