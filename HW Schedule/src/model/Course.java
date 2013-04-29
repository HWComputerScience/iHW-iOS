package model;

public class Course {
	public static final int X_DAY = 0;
	public static final int SINGLE_PERIOD = 1;
	public static final int DOUBLE_BEFORE = 2;
	public static final int DOUBLE_AFTER = 3;
	
	private String name;
	private int period;
	private int[] meetings;
	
	public Course(String name, int period, int[] meetings) {
		this.setName(name);
		this.setPeriod(period);
		this.setMeetings(meetings);
	}

	public String getName() { return name; }
	public void setName(String name) { this.name = name; }
	public int getPeriod() { return period; }
	public void setPeriod(int period) { this.period = period; }

	public int getMeetingOn(int dayNum) {
		return meetings[dayNum-1];
	}

	public void setMeetings(int[] meetings) { this.meetings = meetings; }
}
