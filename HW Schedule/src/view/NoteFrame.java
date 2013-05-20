package view;

import java.awt.*;

import javax.swing.*;

public class NoteFrame extends JFrame {
	private static final long serialVersionUID = 6780081129703009164L;
	private PeriodPanel delegate;
	
	public NoteFrame() {
		this("Add Note", "");
	}
	
	public NoteFrame(String existingText) {
		this("Edit Note", existingText);
	}
	
	private NoteFrame(String title, String existingText) {
		this.setTitle(title);
		Container mainPane = this.getContentPane();
		mainPane.setLayout(new BoxLayout(mainPane, BoxLayout.LINE_AXIS));
		JTextField noteText = new JTextField(existingText);
		noteText.setPreferredSize(new Dimension(50,noteText.getPreferredSize().height));
		noteText.setMaximumSize(new Dimension(500,noteText.getPreferredSize().height));
		noteText.setAlignmentX(Component.LEFT_ALIGNMENT);
		mainPane.add(noteText);
		JButton saveButton = new JButton("Save Note");
		mainPane.add(saveButton);
		this.setSize(new Dimension(300, 50));
		this.setResizable(false);
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.validate();
	}
	
	public PeriodPanel getDelegate() {
		return delegate;
	}
	
	public void setDelegate(PeriodPanel delegate) {
		this.delegate = delegate;
	}
	
}
