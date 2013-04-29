package model;

public class Course {
	public static final int PERIOD_THIS = 1;
	public static final int PERIOD_BEFORE = 2;
	public static final int PERIOD_AFTER = 4;
	
	private String name;
	private int period;
	private int[] meetings;
	
	public Course(String name, int period, int[] meetings) {
		this.setName(name);
		this.setPeriod(period);
		this.setMeetings(meetings);
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getPeriod() {
		return period;
	}

	public void setPeriod(int period) {
		this.period = period;
	}

	public int[] getMeetings() {
		return meetings;
	}

	public void setMeetings(int[] meetings) {
		this.meetings = meetings;
	}
}
