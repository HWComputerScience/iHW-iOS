package view;

import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;

import model.Day;
import model.Holiday;
import model.NormalDay;
import model.Period;
import model.Date;

public class ScheduleFrame extends JFrame {
	private static final long serialVersionUID = -8726369403910041693L;
	private static final double SCALE = 2;
	
	private ScheduleViewDelegate delegate;
	private ScheduleViewDataSource dataSource;
	private JPanel mainPanel;
	private JScrollPane scrollPane;
	private Date[] dateRange;
	private boolean firstTimeDisplayed;
	
	public ScheduleFrame() {
		this.setTitle("HW Schedule");
		mainPanel = new JPanel();
		scrollPane = new JScrollPane(mainPanel);
		JPanel toolbar = new JPanel();
		JButton leftWeek = new JButton("<<");
		leftWeek.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				loadDayRange(getDateRange()[0].dateByAdding(-7), getDateRange()[1].dateByAdding(-7));
			}
		});
		toolbar.add(leftWeek);
		JButton leftDay = new JButton("<");
		leftDay.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				loadDayRange(getDateRange()[0].dateByAdding(-1), getDateRange()[1].dateByAdding(-1));
			}
		});
		toolbar.add(leftDay);
		JButton less = new JButton("Less");
		less.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				loadDayRange(getDateRange()[0], getDateRange()[1].dateByAdding(-1));
			}
		});
		toolbar.add(less);
		JButton more = new JButton("More");
		more.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				loadDayRange(getDateRange()[0], getDateRange()[1].dateByAdding(1));
			}
		});
		toolbar.add(more);
		JButton rightOne = new JButton(">");
		rightOne.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				loadDayRange(getDateRange()[0].dateByAdding(1), getDateRange()[1].dateByAdding(1));
			}
		});
		toolbar.add(rightOne);
		JButton rightWeek = new JButton(">>");
		rightWeek.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				loadDayRange(getDateRange()[0].dateByAdding(7), getDateRange()[1].dateByAdding(7));
			}
		});
		toolbar.add(rightWeek);
		this.getContentPane().setLayout(new BorderLayout());
		this.getContentPane().add(scrollPane, BorderLayout.CENTER);
		this.getContentPane().add(toolbar, BorderLayout.NORTH);
		scrollPane.setMaximumSize(new Dimension(100,100));
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.setMinimumSize(new Dimension(200,200));
		firstTimeDisplayed = true;
		//will set visible to true once a date range is loaded (see below)
	}
	
	public void loadDayRange(Date begin, Date end) {
		dateRange = new Date[] {begin, end};
		if (dataSource==null) return;
		Date d = begin;
		Day day;
		int numDaysDisplayed = begin.getDaysUntil(end)+1;
		mainPanel.removeAll();
		mainPanel.setLayout(new GridLayout(1, numDaysDisplayed, 0, 10));
		mainPanel.setMinimumSize(new Dimension(numDaysDisplayed*200, 200));
		if (firstTimeDisplayed) this.setSize(mainPanel.getMinimumSize());
		firstTimeDisplayed = false;
		while (d.compareTo(end) <= 0) {
			JPanel dayPanel = new JPanel();
			dayPanel.setLayout(new GridBagLayout());
			GridBagConstraints cons = new GridBagConstraints();
			cons.fill = GridBagConstraints.HORIZONTAL;
			cons.weightx = 1;
			cons.weighty = 0;
			cons.gridx = 0;
			cons.gridheight = 1;
			cons.gridwidth = 1;
			cons.anchor = GridBagConstraints.NORTHWEST;
			day = dataSource.getDay(d);
			JLabel title = new JLabel("", JLabel.CENTER);
			title.setFont(new Font("Georgia", Font.BOLD, 14));
			title.setBackground(new Color(153,0,0));
			title.setForeground(Color.WHITE);
			title.setOpaque(true);
			title.setAlignmentX(LEFT_ALIGNMENT);
			if (day instanceof Holiday) {
				String weekdayName = day.getDate().getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.SHORT, getLocale());
				title.setText(weekdayName + ", " + day.getDate().toString());
				dayPanel.add(title, cons);
				JLabel title2 = new JLabel(((Holiday)day).getName(), JLabel.CENTER);
				title2.setFont(new Font("Georgia", Font.PLAIN, 24));
				title2.setBackground(new Color(153,0,0));
				title2.setForeground(Color.WHITE);
				title2.setOpaque(true);
				title2.setAlignmentX(LEFT_ALIGNMENT);
				dayPanel.add(title2, cons);
				cons.weighty = 1;
				dayPanel.add(new JPanel(), cons);
			} else {
				if (day instanceof NormalDay) {
					String weekdayName = day.getDate().getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.SHORT, getLocale());
					title.setText(weekdayName + ", " + day.getDate() + " (Day " + ((NormalDay)day).getDayNumber() + ")");
				} else {
					String weekdayName = day.getDate().getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.SHORT, getLocale());
					title.setText(weekdayName + ", " + day.getDate().toString());
				}
				dayPanel.add(title, cons);
				for (Period p : day.getPeriods()) {
					PeriodPanel pp = new PeriodPanel(p, dataSource.getNotes(d, p.getNum()), SCALE);
					pp.setDelegate(delegate);
					pp.setAlignmentX(LEFT_ALIGNMENT);
					dayPanel.add(pp, cons);
				}
				cons.weighty = 1;
				dayPanel.add(new JPanel(), cons);
			}
			mainPanel.add(dayPanel);
			dayPanel.revalidate();
			d = d.dateByAdding(1);
		}
		this.setVisible(true);
		this.validate();
	}
	
	public Date[] getDateRange() { return dateRange; }
	
	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }

	public ScheduleViewDataSource getDataSource() { return dataSource; }
	public void setDataSource(ScheduleViewDataSource dataSource) { this.dataSource = dataSource; }
}
