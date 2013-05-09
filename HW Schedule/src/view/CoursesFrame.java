package view;

import java.awt.*;
import java.util.*;
import javax.swing.*;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import model.Course;

public class CoursesFrame extends JFrame implements ListSelectionListener {
	private static final long serialVersionUID = 6934883684026565042L;
	private Set<Course> courses;
	private Course selectedCourse;

	public CoursesFrame(Set<Course> courses) {
		this.courses = courses;
		JPanel contentPane = (JPanel)this.getContentPane();
		contentPane.setLayout(new BorderLayout());
		JLabel title = new JLabel("Edit Courses"); // {
			title.setFont(new Font("Georgia", 0, 28));
			title.setBackground(new Color(153,0,0));
			title.setForeground(Color.WHITE);
			title.setOpaque(true);
			title.setHorizontalAlignment(SwingConstants.CENTER);
	//  }
		contentPane.add(title, BorderLayout.NORTH);
		JList list = new JList(); // {
			//TODO: Add course titles to the list
			/*e.g.*/ list.setListData(new String[] {"Course A", "Course B", "Course C"});
			list.setBackground(new Color(235, 229, 207));
			list.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
	//  }
		contentPane.add(list, BorderLayout.CENTER);
		JPanel buttonPanel = new JPanel(); // {
			buttonPanel.setLayout(new GridLayout(1,3));
			JButton addButton = new JButton("Add");
			JButton deleteButton = new JButton("Delete");
			JButton editButton = new JButton("Edit");
			buttonPanel.add(addButton);
			buttonPanel.add(deleteButton);
			buttonPanel.add(editButton);
	//  }
		contentPane.add(buttonPanel, BorderLayout.SOUTH);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.setSize(300, 400);
	}

	public void valueChanged(ListSelectionEvent arg0) {
		// TODO set the selected course
	}
}
