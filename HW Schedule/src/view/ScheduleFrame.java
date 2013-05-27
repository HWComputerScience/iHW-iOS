package view;

import java.awt.*;
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
	
	public ScheduleFrame() {
		mainPanel = new JPanel();
		this.setContentPane(new JScrollPane(mainPanel));
		this.getContentPane().setMaximumSize(new Dimension(100,100));
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.setMinimumSize(new Dimension(200,200));
		//will set visible to true once a date range is loaded (see below)
	}
	
	public void loadDayRange(Date begin, Date end) {
		if (dataSource==null) return;
		Date d = begin;
		Day day;
		int numDaysDisplayed = begin.getDaysUntil(end)+1;
		mainPanel.setLayout(new GridLayout(1, numDaysDisplayed, 0, 10));
		mainPanel.setMinimumSize(new Dimension(numDaysDisplayed*200, 0));
		
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
			if (day instanceof Holiday) {
				JLabel title = new JLabel(day.getDate().toString(), JLabel.CENTER);
				title.setFont(new Font("Georgia", Font.BOLD, 14));
				title.setBackground(new Color(153,0,0));
				title.setForeground(Color.WHITE);
				title.setOpaque(true);
				title.setAlignmentX(LEFT_ALIGNMENT);
				dayPanel.add(title, cons);
				JLabel title2 = new JLabel(((Holiday)day).getName(), JLabel.CENTER);
				title2.setFont(new Font("Georgia", Font.BOLD, 24));
				title2.setBackground(new Color(153,0,0));
				title2.setForeground(Color.WHITE);
				title2.setOpaque(true);
				title2.setAlignmentX(LEFT_ALIGNMENT);
				dayPanel.add(title2, cons);
				cons.weighty = 1;
				dayPanel.add(new JPanel(), cons);
			} else {
				JLabel title;
				if (day instanceof NormalDay) {
					title = new JLabel(day.getDate() + " (Day " + ((NormalDay)day).getDayNumber() + ")", JLabel.CENTER);
				} else {
					title = new JLabel(day.getDate().toString(), JLabel.CENTER);
				}
				title.setFont(new Font("Georgia", Font.BOLD, 14));
				title.setBackground(new Color(153,0,0));
				title.setForeground(Color.WHITE);
				title.setOpaque(true);
				title.setAlignmentX(LEFT_ALIGNMENT);
				dayPanel.add(title, cons);
				for (Period p : day.getPeriods()) {
					PeriodPanel pp = new PeriodPanel(p, dataSource.getNotes(d, p.getNum()), SCALE);
					pp.setAlignmentX(LEFT_ALIGNMENT);
					dayPanel.add(pp, cons);
				}
				cons.weighty = 1;
				dayPanel.add(new JPanel(), cons);
			}
			mainPanel.add(dayPanel);
			dayPanel.revalidate();
			System.out.println(dayPanel.getSize().height);
			d = d.dateByAdding(1);
		}
		this.setVisible(true);
		this.validate();
	}
	
	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }

	public ScheduleViewDataSource getDataSource() { return dataSource; }
	public void setDataSource(ScheduleViewDataSource dataSource) { this.dataSource = dataSource; }
}
