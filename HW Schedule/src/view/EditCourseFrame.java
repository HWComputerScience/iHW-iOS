package view;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.text.*;

import model.Course;

public class EditCourseFrame extends JFrame {
	private static final long serialVersionUID = 412259773568289831L;
	private JTextField nameField;
	private JTextField periodField;
	private JComboBox<String> termBox;
	private Checkbox[][] meetingBoxes;
	private JLabel[] periodHeadings;
	private int numPeriods;
	private CoursesFrame delegate;
	private String oldCourseName;
	
	public EditCourseFrame(int numDays, final int numPeriods) {
		this.numPeriods = numPeriods;
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
				nameField = new JTextField();
				nameField.setAlignmentX(Component.RIGHT_ALIGNMENT);
				namePanel.add(nameField);
				namePanel.setAlignmentX(Component.CENTER_ALIGNMENT);
		//  }
			mainPanel.add(namePanel);
			JPanel periodPanel = new JPanel(); // {
				periodPanel.setLayout(new BoxLayout(periodPanel, BoxLayout.LINE_AXIS));
				periodPanel.add(new JLabel("Period:"));
				periodField = new JTextField();
				periodField.setPreferredSize(new Dimension(50,100));
				periodField.setMaximumSize(new Dimension(50,100));
				periodField.setAlignmentX(Component.LEFT_ALIGNMENT);
				periodPanel.add(periodField);
				periodField.setDocument(new PeriodFieldDocument());
				periodPanel.add(new JLabel("Term:"));
				String[] termNames = new String[6];
				termNames[0] = "Full Year";
				termNames[1] = "1st Semester";
				termNames[2] = "2nd Semester";
				termNames[3] = "1st Trimester";
				termNames[4] = "2nd Trimester";
				termNames[5] = "3rd Trimester";
				termBox = new JComboBox<String>(termNames); //TODO: add terms
				termBox.setAlignmentX(Component.RIGHT_ALIGNMENT);
				periodPanel.add(termBox);
				periodPanel.setAlignmentX(Component.CENTER_ALIGNMENT);
		//  }
			mainPanel.add(periodPanel);
			JLabel meetingsLabel = new JLabel("Check the times when this course meets:");
			meetingsLabel.setAlignmentX(Component.CENTER_ALIGNMENT);
			mainPanel.add(meetingsLabel);
			JPanel meetingsPanel = new JPanel(); // {
				meetingsPanel.setLayout(new GridLayout(4, numDays+1));
				meetingsPanel.add(new JPanel());
				for (int i=1; i<=numDays; i++) meetingsPanel.add(new JLabel("" + i, JLabel.CENTER));
				periodHeadings = new JLabel[3];
				meetingBoxes = new Checkbox[3][numDays];
				for (int r=1; r<=3; r++) for (int c=0; c<=numDays; c++) {
					if (c==0) {
						JLabel heading = new JLabel("", JLabel.CENTER);
						periodHeadings[r-1] = heading;
						heading.setPreferredSize(new Dimension(0,0));
						meetingsPanel.add(heading);
					} else {
						JPanel panel = new JPanel();
						meetingBoxes[r-1][c-1] = new Checkbox();
						panel.add(meetingBoxes[r-1][c-1]);
						panel.setAlignmentX(CENTER_ALIGNMENT);
						panel.setAlignmentY(CENTER_ALIGNMENT);
						meetingsPanel.add(panel);
					}
				}
		//  }
			mainPanel.add(meetingsPanel);
			updateMeetingBoxes(-1);
			JButton submit = new JButton("Save");
			submit.setAlignmentX(CENTER_ALIGNMENT);
			submit.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					Course course = null;
					//TODO: Validate all the form fields, create the new Course object from them, and:
					if (delegate != null) {
						if (oldCourseName != null) delegate.editingExistingCourseFinished(oldCourseName, course);
						else delegate.editingNewCourseFinished(course);
					}
				}
			});
			mainPanel.add(submit);
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
	
	public void fillFieldsFromCourse(Course c) {
		//TODO: fill all of the fields with data from the existing course.
		//Also set the oldCourseName instance variable.
	}
	
	public void updateMeetingBoxes(int period) {
		for (int r=period-1; r<=period+1; r++) {
			if (r<1 || r>numPeriods) {
				periodHeadings[r-period+1].setText("");
				for (int c=0; c<meetingBoxes[r-period+1].length; c++) {
					meetingBoxes[r-period+1][c].setState(false);
					meetingBoxes[r-period+1][c].setEnabled(false);
					meetingBoxes[r-period+1][c].setVisible(false);
				}
			} else {
				String suffix;
				if (r==1) suffix="st";
				else if (r==2) suffix="nd";
				else if (r==3) suffix="rd";
				else suffix="th";
				periodHeadings[r-period+1].setText(""+r+suffix);
				for (int c=0; c<meetingBoxes[r-period+1].length; c++) {
					meetingBoxes[r-period+1][c].setEnabled(true);
					meetingBoxes[r-period+1][c].setVisible(true);
				}
			}
		}
	}
	
	public CoursesFrame getDelegate() { return delegate; }
	public void setDelegate(CoursesFrame delegate) { this.delegate = delegate; }

	/**
	 * Controls the text of the period field in the EditCourseFrame.
	 */
	private class PeriodFieldDocument extends PlainDocument {
		//Validate the input on the period field
		private static final long serialVersionUID = -1111071219926234857L;
		public void insertString(int offset, String str, AttributeSet a) throws BadLocationException {
			String newString = this.getText(0, offset) + str + this.getText(offset, this.getLength()-offset);
			int period=-1;
			try {
				period = Integer.parseInt(newString);
			} catch (Exception e) {	}
			if (period >= 1 && period <= numPeriods) {
				super.insertString(offset, str, a);
				updateMeetingBoxes(period);
			}
		}
		public void remove(int offset, int length) throws BadLocationException {
			String newString = this.getText(0, offset) + this.getText(offset+length, this.getLength()-offset-length);
			int period=-1;
			try {
				period = Integer.parseInt(newString);
			} catch (Exception e) {	}
			super.remove(offset, length);
			updateMeetingBoxes(period);
		}
	}
}
