package view;

import java.awt.*;
import java.awt.event.*;

import javax.swing.*;

public class HomepageFrame extends JFrame {
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
			buttonPanel.setLayout(new GridLayout(6,1));
			buttonPanel.setOpaque(false);
			buttonPanel.add(new EmptyJPanel());
			buttonPanel.add(new EmptyJPanel());
			JButton editCoursesButton = new JButton("Manage Courses");
			editCoursesButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					if (delegate != null) delegate.showCourseEditor();
				}
			});
			buttonPanel.add(editCoursesButton);
			JButton showScheduleButton = new JButton("Show Schedule");
			showScheduleButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					if (delegate != null) delegate.showSchedule();
				}
			});
			buttonPanel.add(showScheduleButton);
			buttonPanel.add(new EmptyJPanel());
			buttonPanel.add(new EmptyJPanel());
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
	
	private class EmptyJPanel extends JPanel {
		private static final long serialVersionUID = 6198562870330941872L;
		public EmptyJPanel() { this.setOpaque(false); }
	}
}
