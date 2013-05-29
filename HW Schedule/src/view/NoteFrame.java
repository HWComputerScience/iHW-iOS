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
		this("Add Note", "", false, false, d, periodNum);
	}
	
	public NoteFrame(Note note, Date d, int periodNum) {
		this("Edit Note", note.getText(), note.isToDo(), note.isChecked(), d, periodNum);
	}
	
	private NoteFrame(String title, final String existingText, boolean isToDo, boolean checked, Date date, int period) {
		this.d=date;
		this.periodNum=period;
		final NoteFrame thisFrame = this;
		this.setTitle(title);
		this.getContentPane().setLayout(new BoxLayout(this.getContentPane(), BoxLayout.LINE_AXIS));
		
		JPanel mainPane = new JPanel();
			mainPane.setLayout(new BoxLayout(mainPane, BoxLayout.PAGE_AXIS));
			final JTextField noteText = new JTextField(existingText);
			noteText.setPreferredSize(new Dimension(50,noteText.getPreferredSize().height));
			noteText.setMaximumSize(new Dimension(500,noteText.getPreferredSize().height));
			noteText.setAlignmentX(Component.LEFT_ALIGNMENT);
			mainPane.add(noteText);
			final JCheckBox cb = new JCheckBox("This note is a to-do");
			mainPane.add(cb);
		this.getContentPane().add(mainPane);
		JButton saveButton = new JButton("Save Note");
		saveButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				if (delegate!=null && !noteText.getText().equals("")) {
					if (existingText.equals("")) delegate.addNote(noteText.getText(), cb.isSelected(), d, periodNum);
					else delegate.replaceNote(noteText.getText(), cb.isSelected(), existingText, d, periodNum);
					thisFrame.dispose();
				} else if (delegate != null && !existingText.equals("")) {
					delegate.removeNote(existingText, d, periodNum);
					thisFrame.dispose();
				}
			}
		});
		this.getContentPane().add(saveButton);
		this.getRootPane().setDefaultButton(saveButton);
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
