package model;

public class Time {
	private int hour;
	private int minute;
	
	public Time(int hour, int minute) {
		this.hour = hour;
		this.minute = minute;
	}
	
	public Time(int hour, int minute, boolean pm) {
		if (pm && hour != 12) this.hour = hour+12;
		else if (!pm && hour == 12) this.hour = hour-12;
		else this.hour = hour;
		this.minute = minute;
	}
	
	public int getHour() { return hour; }
	public int getHour12() { return hour % 12; }
	public void setHour(int hour) { this.hour = hour; }
	public void setHour(int hour, boolean pm) {
		if (pm && hour != 12) this.hour = hour+12;
		else if (!pm && hour == 12) this.hour = hour-12;
		else this.hour = hour;
	}
	public boolean isPM() { return hour >= 12; }
	public int getMinute() { return minute; }
	public void setMinute(int minute) { this.minute = minute; }
}
