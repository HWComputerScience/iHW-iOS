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

	public CoursesFrame(List<String> courses, final int numDays, final int numPeriods) {
		final CoursesFrame thisFrame = this;
		this.courseNames = courses;
		JPanel contentPane = (JPanel)this.getContentPane();
		contentPane.setLayout(new BorderLayout());
		JLabel title = new JLabel("Manage Courses"); // {
			title.setFont(new Font("Georgia", 0, 28));
			title.setBackground(new Color(153,0,0));
			title.setForeground(Color.WHITE);
			title.setOpaque(true);
			title.setHorizontalAlignment(SwingConstants.CENTER);
	//  }
		contentPane.add(title, BorderLayout.NORTH);
		JList list = new JList(); // {
			
			list.setModel(regenerateListItems());
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
					EditCourseFrame ecf = new EditCourseFrame(numDays, numPeriods);
					ecf.setDelegate(thisFrame);
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
					if (dataSource!=null) {
						EditCourseFrame ecf = new EditCourseFrame(numDays, numPeriods);
						ecf.setDelegate(thisFrame);
						ecf.fillFieldsFromCourse(dataSource.getCourse(selectedCourse));
					}
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
	
	private ListModel regenerateListItems() {
		listItems = new DefaultListModel();
		//TODO: Add course titles to the list from the courseNames instance variable, instead of sample data:
		listItems.addElement("Course A");
		listItems.addElement("Course B");
		listItems.addElement("Course C");
		return listItems;
	}

	public void valueChanged(ListSelectionEvent evt) {
		int i = evt.getFirstIndex();
		selectedCourse = courseNames.get(i);
	}
	
	/**
	 * The edit course frame calls this when the user is done editing.
	 * Returns whether or not the course was valid and was added.
	 */
	public boolean editingNewCourseFinished(Course c) {
		//TODO: update the courseNames instance variable
		regenerateListItems();
		if (delegate==null) return false;
		return delegate.addCourse(c);
	}
	
	public boolean editingExistingCourseFinished(String oldName, Course c) {
		//TODO: update teh courseNames instance varilable
		regenerateListItems();
		if (delegate==null) return false;
		return delegate.editCourse(oldName, c);
	}
}
