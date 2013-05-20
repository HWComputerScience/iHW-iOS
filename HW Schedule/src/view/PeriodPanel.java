package view;

import java.util.Iterator;
import java.util.List;
import java.awt.*;
import java.awt.event.*;

import javax.swing.*;

import model.Period;

public class PeriodPanel extends JPanel implements MouseListener {
	private static final long serialVersionUID = -3652755502045723337L;
	private List<String> lines;
	
	public PeriodPanel(Period p, List<String> bodyLines, double heightFactor) {
		final PeriodPanel thisPanel = this;
		this.lines = bodyLines;
		int height = (int)(p.getStartTime().minutesUntil(p.getEndTime())*heightFactor);
		this.setMinimumSize(new Dimension(200,height));
		this.setPreferredSize(new Dimension(0,height));
		this.setMaximumSize(new Dimension(Short.MAX_VALUE,height));
		this.setBorder(BorderFactory.createLineBorder(Color.BLACK));
		this.setBackground(Color.WHITE);
		
		this.setLayout(new BorderLayout());
		JPanel topPanel = new JPanel();
			topPanel.setLayout(new BoxLayout(topPanel, BoxLayout.LINE_AXIS));
			topPanel.add(new JLabel(p.getStartTime().toString12()+ "  " + p.getName()));
			topPanel.setBackground(Color.LIGHT_GRAY);
		this.add(topPanel, BorderLayout.NORTH);
		JPanel bottomPanel = new JPanel();
			bottomPanel.setLayout(new BorderLayout());
			bottomPanel.add(new JLabel(p.getEndTime().toString12()), BorderLayout.WEST);
			JButton add = new JButton("Add");
			add.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					new NoteFrame().setDelegate(thisPanel);
				}
			});
			bottomPanel.add(add, BorderLayout.EAST);
			bottomPanel.setBackground(Color.LIGHT_GRAY);
		this.add(bottomPanel, BorderLayout.SOUTH);
		JTextArea notes = new JTextArea();
			notes.setLineWrap(true);
			String text = "";
			Iterator<String> iter = lines.iterator();
			while (iter.hasNext()) {
				text += iter.next() + "\n";
			}
			text += "\n";
			text = text.substring(0,text.length()-1);
			notes.setText(text);
			notes.setEditable(false);
			notes.setCursor(new Cursor(Cursor.HAND_CURSOR));
			notes.addMouseListener(this);
		this.add(notes, BorderLayout.CENTER);
	}
	
	public void mousePressed(MouseEvent evt) {
		int position = ((JTextArea)evt.getComponent()).viewToModel(evt.getPoint());
		Iterator<String> iter = lines.iterator();
		int line=-1;
		while (position >= 0) {
			if (!iter.hasNext()) return;
			position -= iter.next().length() + 1;
			line++;
		}
		//System.out.println("Line Clicked: " + line);
		new NoteFrame(lines.get(line)).setDelegate(this);
	}
	
	public void mouseClicked(MouseEvent arg0) { }
	public void mouseEntered(MouseEvent arg0) { }
	public void mouseExited(MouseEvent arg0) { }
	public void mouseReleased(MouseEvent arg0) { }
}
