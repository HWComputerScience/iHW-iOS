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
				namePanel.add(new JLabel("Course Name:"));
				JTextField nameField = new JTextField();
				nameField.setMinimumSize(new Dimension(100, 25));
				namePanel.add(nameField);
		//  }
			mainPanel.add(namePanel);
			JPanel periodPanel = new JPanel(); // {
				periodPanel.add(new JLabel("Period:"));
				JTextField periodField = new JTextField();
				nameField.setMinimumSize(new Dimension(40, 25));
				periodPanel.add(periodField);
		//  }
			mainPanel.add(periodPanel);
			JPanel termPanel = new JPanel(); // {
				termPanel.add(new JLabel("Term:"));
				JComboBox termBox = new JComboBox(new String[]{}); //TODO: add terms
				termPanel.add(termBox);
		//  }
			mainPanel.add(termPanel);
			mainPanel.add(new JLabel("Check meetings for this course"));
			JPanel meetingsPanel = new JPanel(); // {
				
		//  }
			mainPanel.add(meetingsPanel);
	//  }
		contentPane.add(mainPanel, BorderLayout.CENTER);
		this.setSize(300, 400);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
	}
}
