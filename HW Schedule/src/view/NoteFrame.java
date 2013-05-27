package view;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

import model.Date;
import model.Note;

public class NoteFrame extends JFrame {
	private static final long serialVersionUID = 6780081129703009164L;
	private ScheduleViewDelegate delegate;
	private Date d;
	private int periodNum;
	
	public NoteFrame(Date d, int periodNum) {
		this("Add Note", "", d, periodNum);
	}
	
	public NoteFrame(Note note, Date d, int periodNum) {
		this("Edit Note", note.getText(), d, periodNum);
	}
	
	private NoteFrame(String title, final String existingText, Date date, int period) {
		this.d=date;
		this.periodNum=period;
		final NoteFrame thisFrame = this;
		this.setTitle(title);
		this.getContentPane().setLayout(new BoxLayout(this.getContentPane(), BoxLayout.PAGE_AXIS));
		JPanel mainPane = new JPanel();
			mainPane.setLayout(new BoxLayout(mainPane, BoxLayout.LINE_AXIS));
			final JTextField noteText = new JTextField(existingText);
			noteText.setPreferredSize(new Dimension(50,noteText.getPreferredSize().height));
			noteText.setMaximumSize(new Dimension(500,noteText.getPreferredSize().height));
			noteText.setAlignmentX(Component.LEFT_ALIGNMENT);
			mainPane.add(noteText);
			JButton saveButton = new JButton("Save Note");
			saveButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent arg0) {
					if (delegate!=null) {
						if (existingText.equals("")) delegate.addNote(noteText.getText(), d, periodNum);
						else delegate.replaceNote(noteText.getText(), existingText, d, periodNum);
					}
					thisFrame.setVisible(false);
					thisFrame.dispose();
				}
			});
			mainPane.add(saveButton);
		this.getContentPane().add(mainPane);
		this.getContentPane().add(new Checkbox("This note is a to-do"));
		this.setSize(new Dimension(300, 80));
		this.setResizable(false);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.validate();
	}
	
	public ScheduleViewDelegate getDelegate() {
		return delegate;
	}
	
	public void setDelegate(ScheduleViewDelegate delegate) {
		this.delegate = delegate;
	}
	
}
