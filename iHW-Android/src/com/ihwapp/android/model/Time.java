package com.ihwapp.android.model;

public class Time /*implements org.json.JSONString*/ {
	private int hour;
	private int minute;
	private int second;
	
	public Time() {
		Date now = new Date();
		this.hour = now.get(Date.HOUR_OF_DAY);
		this.minute = now.get(Date.MINUTE);
		this.second = now.get(Date.SECOND);
	}
	
	/**
	 * Constructs a new time from the specified hour (0-23) and minute (0-59).
	 */
	public Time(int hour, int minute) {
		if (hour<0 || hour>23 || minute<0 || minute>59) throw new IllegalArgumentException();
		this.hour = hour;
		this.minute = minute;
		this.second = 0;
	}
	
	/**
	 * Constructs a new time from the specified hour (1-12), minute (0-59), and am/pm state.
	 */
	public Time(int hour, int minute, boolean pm) {
		if (hour<1 || hour>12 || minute<0 || minute>59) throw new IllegalArgumentException();
		if (pm && hour != 12) this.hour = hour+12;
		else if (!pm && hour == 12) this.hour = hour-12;
		else this.hour = hour;
		this.minute = minute;
		this.second = 0;
	}
	
	public Time(String json) {
		String[] arr = json.split(":");
		this.setHour(Integer.parseInt(arr[0]));
		this.setMinute(Integer.parseInt(arr[1]));
	}

	/**
	 * Returns the hour (0-23) of this time.
	 */
	public int getHour() { return hour; }
	
	/**
	 * Returns the hour (1-12) of this time.
	 */
	public int getHour12() { 
		int ret = hour % 12;
		if (ret==0) ret=12;
		return ret;
	}
	
	/**
	 * Sets the hour (0-23) of this time.
	 */
	public void setHour(int hour) { 
		if (hour<0 || hour>23) throw new IllegalArgumentException();
		this.hour = hour;
	}
	
	/**
	 * Sets the hour (1-12) of this time.
	 */
	public void setHour(int hour, boolean pm) {
		if (hour<0 || hour>12) throw new IllegalArgumentException();
		if (pm && hour != 12) this.hour = hour+12;
		else if (!pm && hour == 12) this.hour = hour-12;
		else this.hour = hour;
	}
	
	/**
	 * Returns whether or not this time represents a PM time.
	 */
	public boolean isPM() { return hour >= 12; }
	
	/**
	 * Returns the minute of this time.
	 */
	public int getMinute() { return minute; }
	
	/**
	 * Sets the minute (0-59) of this time.
	 */
	public void setMinute(int minute) {
		if (minute<0 || minute>59) throw new IllegalArgumentException();
		this.minute = minute;
	}
	
	/**
	 * Returns the second of this time.
	 */
	public int getSecond() {
		return this.second;
	}
	
	/**
	 * Sets the second (0-59) of this time.
	 */
	public void setSecond(int second) {
		if (second<0 || second>59) throw new IllegalArgumentException();
		this.second = second;
	}
	
	/**
	 * Creates and returns a new Time by adding the
	 * specified number of hours and minutes to this time.
	 * Leaves this time unmodified.
	 */
	public Time timeByAdding(int hours, int minutes) {
		int newHours = this.hour+hours;
		int newMinutes = this.minute+minutes;
		if (minutes>=0 && hours>=0) {
			while (newMinutes >= 60) {
				newHours++;
				newMinutes-=60;
			}
			newHours = newHours%24;
			Time newTime = new Time(newHours, newMinutes);
			newTime.second = this.second;
			return newTime;
		} else if (minutes<=0 && hours<=0) {
			while (newMinutes < 0) {
				newHours--;
				newMinutes+=60;
			}
			while (newHours<0) {
				newHours+=24;
			}
			newHours = newHours%24;
			Time newTime = new Time(newHours, newMinutes);
			newTime.second = this.second;
			return newTime;
		}
		throw new IllegalArgumentException();
	}
	
	/**
	 * Returns the number of minutes from this time until the specified time.
	 */
	public int minutesUntil(Time t) {
		return 60*(t.hour-this.hour) + t.minute-this.minute;
	}
	
	public int secondsUntil(Time t) {
		return 60*minutesUntil(t) + t.second-this.second;
	}
	
	/**
	 * Returns a string representation of this time in 24-hour format.
	 */
	public String toString() {
		String minute = "" + getMinute();
		if (minute.length() == 1) minute = "0" + minute;
		return getHour() + ":" + minute;
	}
	
	/**
	 * Returns a string representation of this time in 12-hour format.
	 */
	public String toString12() {
		String ampm;
		if (isPM()) ampm = "PM";
		else ampm = "AM";
		String minute = "" + getMinute();
		if (minute.length() == 1) minute = "0" + minute;
		return getHour12() + ":" + minute + " " + ampm;
	}
	
	/*
	@Override
	public String toJSONString() {
		return "\"" + hour + ":" + minute + "\"";
	}
	*/
}
