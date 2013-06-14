package view;

import java.awt.*;
import java.util.List;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.event.*;

public class CoursesFrame extends JFrame implements ListSelectionListener {
	private static final long serialVersionUID = 6934883684026565042L;
	private List<String> courseNames;
	private JList list;
	private String selectedCourse;
	private DefaultListModel listItems;
	private ScheduleViewDelegate delegate;
	private ScheduleViewDataSource dataSource;
	
	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }
	public ScheduleViewDataSource getDataSource() { return dataSource; }
	public void setDataSource(ScheduleViewDataSource dataSource) { this.dataSource = dataSource; }

	public CoursesFrame(final int numDays, final int numPeriods) {
		this.courseNames = new ArrayList<String>();
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
		list = new JList(); // {
			list.addListSelectionListener(this);
			listItems = new DefaultListModel();
			list.setModel(listItems);
			list.setBackground(new Color(235, 229, 207));
			list.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
	//  }
		list.addMouseListener(new MouseAdapter() {
		    public void mouseClicked(MouseEvent evt) {
		        if (evt.getClickCount() == 2 && dataSource != null && selectedCourse != null) {
					EditCourseFrame ecf = new EditCourseFrame(numDays, numPeriods);
					ecf.setDelegate(delegate);
					ecf.fillFieldsFromCourse(dataSource.getCourse(selectedCourse));
		        }
		    }
		});
		contentPane.add(new JScrollPane(list), BorderLayout.CENTER);
		JPanel buttonPanel = new JPanel(); // {
			buttonPanel.setLayout(new GridLayout(1,3));
			JButton addButton = new JButton("Add");
			JButton deleteButton = new JButton("Delete");
			JButton editButton = new JButton("Edit");
			addButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					if (delegate != null) {
						EditCourseFrame ecf = new EditCourseFrame(numDays, numPeriods);
						ecf.setDelegate(delegate);
					}
				}
			});
			deleteButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					if (selectedCourse != null && delegate != null) 
						delegate.deleteCourse(selectedCourse);
				}
			});
			editButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					if (dataSource != null && selectedCourse != null) {
						EditCourseFrame ecf = new EditCourseFrame(numDays, numPeriods);
						ecf.setDelegate(delegate);
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
	
	public void regenerateListItems(List<String> courses) {
		courseNames = courses;
		listItems.removeAllElements();
		for (String name : courseNames) {
			listItems.addElement(name);
		}
		list.updateUI();
		list.repaint();
	}

	public void valueChanged(ListSelectionEvent evt) {
		int i = ((JList)evt.getSource()).getAnchorSelectionIndex();
		if (i>=0 && i<courseNames.size()) selectedCourse = courseNames.get(i);
		else selectedCourse = null;
	}
}
