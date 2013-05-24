package view;

import java.awt.*;
import java.util.*;
import javax.swing.*;

import model.Note;
import model.Period;
import model.Time;
import model.Date;

public class ScheduleFrame extends JFrame {
	private static final long serialVersionUID = -8726369403910041693L;
	
	private ScheduleViewDelegate delegate;
	private ScheduleViewDataSource dataSource;
	private JPanel mainPanel;
	
	public ScheduleFrame() {
		mainPanel = new JPanel();
		this.setContentPane(new JScrollPane(mainPanel));
		this.getContentPane().setMaximumSize(new Dimension(100,100));
		mainPanel.setLayout(new BoxLayout(mainPanel, BoxLayout.PAGE_AXIS));
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.setMinimumSize(new Dimension(200,200));
		//will set visible to true once a date range is loaded (see below)
		loadDayRange(null,null);
	}
	
	public void loadDayRange(Date begin, Date end) {
		LinkedList<String> lines = new LinkedList<String>();
		lines.add("Hello, World");
		lines.add("Here's another note, and it's really really really really long.");
		lines.add("Here's a third");
		mainPanel.add(new PeriodPanel(new Period("Test Period", new Date(1,9,2012), new Time(8,0), new Time(8,45), 1), lines, 3.5));
		Dimension minSize = new Dimension(0,0);
		Dimension prefSize = new Dimension(0,0);
		Dimension maxSize = new Dimension(Short.MAX_VALUE, Short.MAX_VALUE);
		mainPanel.add(new Box.Filler(minSize, prefSize, maxSize));
		this.setVisible(true);
		this.validate();
	}
	
	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }

	public ScheduleViewDataSource getDataSource() { return dataSource; }
	public void setDataSource(ScheduleViewDataSource dataSource) { this.dataSource = dataSource; }
}
