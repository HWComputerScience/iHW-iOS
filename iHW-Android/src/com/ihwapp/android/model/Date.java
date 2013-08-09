package com.ihwapp.android.model;

import java.util.*;

public class Date extends GregorianCalendar {
	private static final long serialVersionUID = -3262778562693738900L;

	public Date() {
		super();
	}
	
	public Date(int month, int day, int year) {
		super(year, month-1, day);
	}
	
	public Date(String json) {
		super(0,0,0);
		String[] arr = json.split("/");
		this.set(Integer.parseInt(arr[2]), Integer.parseInt(arr[0])-1, Integer.parseInt(arr[1]));
	}

	public int getDay() {
		return this.get(DAY_OF_MONTH);
	}
	
	public int getMonth() {
		return this.get(MONTH)+1;
	}
	
	public int getYear() {
		return this.get(YEAR);
	}
	
	public boolean isMonday() {
		return (this.get(DAY_OF_WEEK) == MONDAY);
	}
	
	public boolean isWeekend() {
		return (this.get(DAY_OF_WEEK) == SATURDAY || this.get(DAY_OF_WEEK) == SUNDAY);
	}
	
	public Date dateByAdding(int days) {
		Date toReturn = (Date)this.clone();
		toReturn.add(GregorianCalendar.DAY_OF_MONTH, days);
		return toReturn;
	}
	
	public Date dateOfNextSunday() {
		int dayOfWeek = this.get(Date.DAY_OF_WEEK);
		int daysBehind = (8-dayOfWeek)%7;
		return dateByAdding(daysBehind);
	}
	
	public Date dateOfPreviousSunday() {
		int dayOfWeek = this.get(Date.DAY_OF_WEEK);
		int daysAhead = dayOfWeek-1;
		return dateByAdding(-daysAhead);
	}
	
	public String toString() {
		return getMonth() + "/" + getDay() + "/" + getYear();
	}

	public int getDaysUntil(Date end) {
		long diff = end.getTimeInMillis()-this.getTimeInMillis();
		return (int)(diff/86400000);
	}
	
	public String getDayOfWeek(boolean shortVersion) {
		if (shortVersion) return this.getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.SHORT, Locale.getDefault());
		else return this.getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.LONG, Locale.getDefault());
	}
	
	public boolean equals(Object other) {
		if (!(other instanceof Date)) return false;
		Date otherDate = (Date)other;
		return (this.getMonth()==otherDate.getMonth()) && 
				(this.getDay() == otherDate.getDay()) && 
				(this.getYear() == otherDate.getYear());
	}
}
