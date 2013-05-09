package view;

import java.awt.*;
import java.awt.event.*;
import java.util.List;
import javax.swing.*;
import javax.swing.event.*;

public class CoursesFrame extends JFrame implements ListSelectionListener {
	private static final long serialVersionUID = 6934883684026565042L;
	private List<String> courseNames;
	private String selectedCourse;
	private DefaultListModel listItems;

	public CoursesFrame(List<String> courses) {
		this.courseNames = courses;
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
			listItems = new DefaultListModel();
			//TODO: Add course titles to the list, instead of sample data:
			listItems.addElement("Course A");
			listItems.addElement("Course B");
			listItems.addElement("Course C");
			list.setModel(listItems);
			list.setBackground(new Color(235, 229, 207));
			list.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
	//  }
		contentPane.add(new JScrollPane(list), BorderLayout.CENTER);
		JPanel buttonPanel = new JPanel(); // {
			buttonPanel.setLayout(new GridLayout(1,3));
			JButton addButton = new JButton("Add");
			JButton deleteButton = new JButton("Delete");
			JButton editButton = new JButton("Edit");
			addButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					// TODO remove the currently selected course from course list
					// inform the controller
					// reload data
				}
			});
			deleteButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					// TODO show the edit course frame
				}
			});
			editButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					// TODO show the edit course frame 
					//with currently course info preloaded
				}
			});
			buttonPanel.add(addButton);
			buttonPanel.add(deleteButton);
			buttonPanel.add(editButton);
	//  }
		contentPane.add(buttonPanel, BorderLayout.SOUTH);
		this.setSize(300, 400);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
	}

	public void valueChanged(ListSelectionEvent evt) {
		int i = evt.getFirstIndex();
		selectedCourse = courseNames.get(i);
	}
}
