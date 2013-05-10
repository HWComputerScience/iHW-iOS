package view;

import java.awt.*;
import java.awt.event.*;
import java.util.List;
import javax.swing.*;
import javax.swing.event.*;

import model.Course;

public class CoursesFrame extends JFrame implements ListSelectionListener {
	private static final long serialVersionUID = 6934883684026565042L;
	private List<String> courseNames;
	private String selectedCourse;
	private DefaultListModel listItems;
	private ScheduleViewDelegate delegate;
	private ScheduleViewDataSource dataSource;
	
	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }
	public ScheduleViewDataSource getDataSource() { return dataSource; }
	public void setDataSource(ScheduleViewDataSource dataSource) { this.dataSource = dataSource; }

	public CoursesFrame(List<String> courses, final int numPeriods, final int numDays) {
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
			
			list.setModel(regenerateListItems(courses));
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
					new EditCourseFrame(null, numDays);
				}
			});
			deleteButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					// TODO remove the currently selected course from course list
					// inform the controller
					// reload data
				}
			});
			editButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					if (dataSource!=null) new EditCourseFrame(dataSource.getCourse(selectedCourse), numDays);
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
	
	private ListModel regenerateListItems(List<String> courses) {
		listItems = new DefaultListModel();
		//TODO: Add course titles to the list, instead of sample data:
		listItems.addElement("Course A");
		listItems.addElement("Course B");
		listItems.addElement("Course C");
		return listItems;
	}

	public void valueChanged(ListSelectionEvent evt) {
		int i = evt.getFirstIndex();
		selectedCourse = courseNames.get(i);
	}
}
