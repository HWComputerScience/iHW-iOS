package com.ihwapp.android.model;

import java.util.*;

import org.json.*;

public class NormalDay extends Day {
	private int dayNumber;
	private boolean hasBreak;
	private int numPeriods;
	private int periodsBeforeBreak;
	private int periodsAfterBreak;
	private int periodLength;
	private int breakLength;
	private String breakName;
	
	/**
	 * Used to initialize a normal day that has an activities period or assembly.
	 */
	public NormalDay(Date d, 
					 Curriculum c,
					 int dayNum, 
					 int periodsBeforeBreak, 
					 int periodsAfterBreak, 
					 int breakLength, 
					 String breakName, 
					 int pLength) {
		super(d);
		this.periodsBeforeBreak = periodsBeforeBreak;
		this.periodsAfterBreak = periodsAfterBreak;
		this.breakLength=breakLength;
		this.breakName=breakName;
		this.dayNumber=dayNum;
		hasBreak = true;
		periodLength = pLength;
		periods = new ArrayList<Period>();
		//if (c!=null) fillPeriods(c); 
	}
	
	/**
	 * Used to initialize a normal day that does not have an activities period or assembly.
	 */
	public NormalDay(Date d, 
					Curriculum c, 
					int dayNum,
					int numPeriods, 
					int pLength) {
		super(d);
		hasBreak = false;
		periodLength = pLength;
		dayNumber = dayNum;
		periods = new ArrayList<Period>();
		//if (c!= null) fillPeriods(c);
	}
	
	public NormalDay(JSONObject obj) {
		super(obj);
		try {
			dayNumber = obj.optInt("dayNumber");
			hasBreak = obj.getBoolean("hasBreak");
			periodLength = obj.getInt("periodLength");
			numPeriods = obj.getInt("numPeriods");
			if (hasBreak) {
				periodsBeforeBreak = obj.getInt("periodsBeforeBreak");
				periodsAfterBreak = obj.getInt("periodsAfterBreak");
				breakLength = obj.getInt("breakLength");
				breakName = obj.getString("breakName");
			}
		} catch (JSONException e) {}
		periods = new ArrayList<Period>();
	}
	
	public void fillPeriods(Curriculum c) {
		if (hasBreak) {
			periods = new ArrayList<Period>(periodsBeforeBreak+periodsAfterBreak+1);
			Time nextStart = new Time(8,0);
			//add periods before break
			for (int num=1; num<=periodsBeforeBreak; num++) {
				Course course = c.getCourse(date, num);
				if (course==null) periods.add(new Period("X", date, nextStart, nextStart.timeByAdding(0, periodLength), num));
				else periods.add(new Period(course.getName(), date, nextStart, nextStart.timeByAdding(0, periodLength), num));
				nextStart = nextStart.timeByAdding(0, periodLength+c.getPassingPeriodLength());
			}
			//add break
			periods.add(new Period(breakName, date, nextStart, nextStart.timeByAdding(0, breakLength), 0));
			nextStart = nextStart.timeByAdding(0, breakLength+c.getPassingPeriodLength());
			//add periods after break
			for (int num=periodsBeforeBreak+1; num<=periodsBeforeBreak+periodsAfterBreak; num++) {
				Course course = c.getCourse(date, num);
				if (course==null) periods.add(new Period("X", date, nextStart, nextStart.timeByAdding(0, periodLength), num));
				else periods.add(new Period(course.getName(), date, nextStart, nextStart.timeByAdding(0, periodLength), num));
				nextStart = nextStart.timeByAdding(0, periodLength+c.getPassingPeriodLength());
			}
		} else {
			periods = new ArrayList<Period>(numPeriods);
			Time nextStart = new Time(8,0);
			//add all periods
			for (int num=1; num<=numPeriods; num++) {
				Course course = c.getCourse(date, num);
				if (course==null) periods.add(new Period("X", date, nextStart, nextStart.timeByAdding(0, periodLength), num));
				else periods.add(new Period(course.getName(), date, nextStart, nextStart.timeByAdding(0, periodLength), num));
				nextStart = nextStart.timeByAdding(0, periodLength+c.getPassingPeriodLength());
			}
		}
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
		try {
			obj.put("type", "normal");
			obj.put("dayNumber", dayNumber);
			obj.put("hasBreak", hasBreak);
			obj.put("periodLength", periodLength);
			obj.put("numPeriods", numPeriods);
			if (hasBreak) {
				obj.put("periodsBeforeBreak", periodsBeforeBreak);
				obj.put("periodsAfterBreak", periodsAfterBreak);
				obj.put("breakLength", breakLength);
				obj.put("breakName", breakName);
			}
		} catch (JSONException e) {}
		return obj;
	}
	
	public String getTitle() {
		//String weekdayName = getDate().getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.SHORT, Locale.getDefault());
		//String title = weekdayName + ", " + getDate().toString();
		String title = super.getTitle();
		if (this.getDayNumber() > 0) title += " (Day " + getDayNumber() + ")";
		return title;
	}
	
	public int getDayNumber() { return dayNumber; }
	public boolean hasBreak() { return hasBreak; }
	public int getPeriodLength() { return periodLength; }
}
