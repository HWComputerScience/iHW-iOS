package view;

import java.awt.*;

import javax.swing.*;

import model.Course;

public class EditCourseFrame extends JFrame {
	private static final long serialVersionUID = 412259773568289831L;
	
	public EditCourseFrame(Course course) {
		JPanel contentPane = (JPanel)this.getContentPane();
		contentPane.setLayout(new BorderLayout());
		JLabel title = new JLabel("Edit Course"); // {
			title.setFont(new Font("Georgia", 0, 28));
			title.setBackground(new Color(153,0,0));
			title.setForeground(Color.WHITE);
			title.setOpaque(true);
			title.setHorizontalAlignment(SwingConstants.CENTER);
	//  }
		contentPane.add(title, BorderLayout.NORTH);
		JPanel mainPanel = new JPanel(); // {
			mainPanel.setLayout(new BoxLayout(mainPanel, BoxLayout.PAGE_AXIS));
			JPanel namePanel = new JPanel(); // {
				namePanel.setLayout(new BoxLayout(namePanel, BoxLayout.LINE_AXIS));
				namePanel.add(new JLabel("Course Name:"));
				JTextField nameField = new JTextField();
				nameField.setAlignmentX(Component.RIGHT_ALIGNMENT);
				namePanel.add(nameField);
				namePanel.setAlignmentX(Component.CENTER_ALIGNMENT);
		//  }
			mainPanel.add(namePanel);
			JPanel periodPanel = new JPanel(); // {
				periodPanel.setLayout(new BoxLayout(periodPanel, BoxLayout.LINE_AXIS));
				periodPanel.add(new JLabel("Period:"));
				JTextField periodField = new JTextField();
				periodField.setPreferredSize(new Dimension(50,100));
				periodField.setMaximumSize(new Dimension(50,100));
				periodField.setAlignmentX(Component.LEFT_ALIGNMENT);
				periodPanel.add(periodField);
				periodPanel.add(new JLabel("Term:"));
				JComboBox termBox = new JComboBox(new String[]{}); //TODO: add terms
				termBox.setAlignmentX(Component.RIGHT_ALIGNMENT);
				periodPanel.add(termBox);
				periodPanel.setAlignmentX(Component.CENTER_ALIGNMENT);
		//  }
			mainPanel.add(periodPanel);
			JLabel meetingsLabel = new JLabel("Check the times when this course meets:");
			meetingsLabel.setAlignmentX(Component.CENTER_ALIGNMENT);
			mainPanel.add(meetingsLabel);
			JPanel meetingsPanel = new JPanel(); // {
				
		//  }
			mainPanel.add(meetingsPanel);
			Dimension minSize = new Dimension(0,0);
			Dimension prefSize = new Dimension(Short.MAX_VALUE, Short.MAX_VALUE);
			Dimension maxSize = new Dimension(Short.MAX_VALUE, Short.MAX_VALUE);
			mainPanel.add(new Box.Filler(minSize, prefSize, maxSize));
	//  }
		contentPane.add(mainPanel, BorderLayout.CENTER);
		this.setSize(300, 400);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
	}
}
