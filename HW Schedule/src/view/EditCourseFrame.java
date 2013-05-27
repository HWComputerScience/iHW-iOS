package view;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.text.*;

import model.Course;

public class EditCourseFrame extends JFrame implements ActionListener {
	private static final long serialVersionUID = 412259773568289831L;
	private static final String[] termNames = new String[] {
		"Full Year",
		"1st Semester",
		"2nd Semester",
		"1st Trimester",
		"2nd Trimester",
		"3rd Trimester"
	};
	
	private JTextField nameField;
	private JTextField periodField;
	private JComboBox termBox;
	private JCheckBox[][] meetingBoxes;
	private JLabel[] periodHeadings;
	private int numDays;
	private int numPeriods;
	private ScheduleViewDelegate delegate;
	private String oldCourseName;
	
	public EditCourseFrame(int numDays, final int numPeriods) {
		this.numDays = numDays;
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
				termBox = new JComboBox(termNames);
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
				meetingBoxes = new JCheckBox[3][numDays];
				for (int r=1; r<=3; r++) for (int c=0; c<=numDays; c++) {
					if (c==0) {
						JLabel heading = new JLabel("", JLabel.CENTER);
						periodHeadings[r-1] = heading;
						heading.setPreferredSize(new Dimension(0,0));
						meetingsPanel.add(heading);
					} else {
						JPanel panel = new JPanel();
						JCheckBox cb = new JCheckBox();
						cb.addActionListener(this);
						cb.setActionCommand("" + (r-1) + "/" + (c-1));
						meetingBoxes[r-1][c-1] = cb;
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
				public void actionPerformed(ActionEvent evt) { submit(); }
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
	
	public void submit() {
		int[] meetings = new int[numDays];
		for (int i=0; i<numDays; i++) {
			if (!meetingBoxes[1][i].isSelected()) meetings[i] = Course.MEETING_X_DAY;
			else if (meetingBoxes[0][i].isSelected()) meetings[i] = Course.MEETING_DOUBLE_BEFORE;
			else if (meetingBoxes[2][i].isSelected()) meetings[i] = Course.MEETING_DOUBLE_AFTER;
			else meetings[i] = Course.MEETING_SINGLE_PERIOD;
		}
		Course course = new Course(nameField.getText(), 
				Integer.parseInt(periodField.getText()), 
				termBox.getSelectedIndex(),
				meetings);
		if (delegate != null) {
			if (oldCourseName != null) {
				if (delegate.editCourse(oldCourseName, course)) {
					this.dispose();
				} else {
					JOptionPane.showMessageDialog(new JFrame(), "The course meetings you selected conflict with one or more of your other courses. Please change them and try again.", "HW Schedule",JOptionPane.WARNING_MESSAGE);
				}
			} else {
				if (delegate.addCourse(course)) {
					this.dispose();
				} else {
					JOptionPane.showMessageDialog(new JFrame(), "The course meetings you selected conflict with one or more of your other courses. Please change them and try again.", "HW Schedule",JOptionPane.WARNING_MESSAGE);
				}
			}
		}
	}
	
	public void fillFieldsFromCourse(Course c) {
		oldCourseName = c.getName();
		nameField.setText(c.getName());
		periodField.setText("" + c.getPeriod());
		updateMeetingBoxes(c.getPeriod());
		termBox.setSelectedIndex(c.getTerm());
		for (int i=1; i<=numDays; i++) {
			if (c.getMeetingOn(i) == Course.MEETING_SINGLE_PERIOD) meetingBoxes[1][i-1].setSelected(true);
			else if (c.getMeetingOn(i) == Course.MEETING_DOUBLE_BEFORE) {
				meetingBoxes[0][i-1].setSelected(true);
				meetingBoxes[1][i-1].setSelected(true);
			} else if (c.getMeetingOn(i) == Course.MEETING_DOUBLE_AFTER) {
				meetingBoxes[1][i-1].setSelected(true);
				meetingBoxes[2][i-1].setSelected(true);
			}
		}
	}
	
	public void updateMeetingBoxes(int period) {
		for (int r=period-1; r<=period+1; r++) {
			if (r<1 || r>numPeriods) {
				periodHeadings[r-period+1].setText("");
				for (int c=0; c<meetingBoxes[r-period+1].length; c++) {
					meetingBoxes[r-period+1][c].setSelected(false);
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
	
	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }

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
	
	public void actionPerformed(ActionEvent evt) {
		String[] loc = evt.getActionCommand().split("/");
		int r = Integer.parseInt(loc[0]);
		int c = Integer.parseInt(loc[1]);
		boolean state = ((JCheckBox)evt.getSource()).isSelected();
		if (r==1 && state==false) {
			meetingBoxes[0][c].setSelected(false);
			meetingBoxes[2][c].setSelected(false);
		} else if (r!=1 && state==true) {
			meetingBoxes[1][c].setSelected(true);
		}
	}
}
