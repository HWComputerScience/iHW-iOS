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
	private boolean breakIsFree;
	private String breakName;
	private int[] periodLengths;
	
	/**
	 * Used to initialize a normal day that has an activities period or assembly.
	 */
	public NormalDay(Date d, 
					 int dayNum,
					 int periodsBeforeBreak, 
					 int periodsAfterBreak, 
					 int breakLength, 
					 String breakName, 
					 int pLength,
					 boolean breakIsFree) {
		super(d);
		this.periodsBeforeBreak = periodsBeforeBreak;
		this.periodsAfterBreak = periodsAfterBreak;
        this.numPeriods = periodsBeforeBreak+periodsAfterBreak;
		this.breakLength=breakLength;
		this.breakName=breakName;
		this.dayNumber=dayNum;
		this.breakIsFree = breakIsFree;
		hasBreak = true;
		periodLength = pLength;
		periods = new ArrayList<Period>();
		//if (c!=null) fillPeriods(c); 
	}
	
	/**
	 * Used to initialize a normal day that does not have an activities period or assembly.
	 */
	public NormalDay(Date d, 
					int dayNum,
					int numPeriods, 
					int pLength) {
		super(d);
		hasBreak = false;
		periodLength = pLength;
        this.numPeriods = numPeriods;
        this.periodsBeforeBreak = numPeriods;
        this.periodsAfterBreak = 0;
		dayNumber = dayNum;
		periods = new ArrayList<Period>();
	}
	
	public NormalDay(JSONObject obj) {
		super(obj);
		try {
			dayNumber = obj.optInt("dayNumber");
			hasBreak = obj.getBoolean("hasBreak");
			periodLength = obj.getInt("periodLength");
			numPeriods = obj.getInt("numPeriods");
			JSONObject lengthsObj = obj.optJSONObject("periodLengths");
			if (lengthsObj != null) {
				periodLengths = new int[numPeriods+1];
				for (int i=0; i<periodLengths.length; i++) {
					periodLengths[i] = -1;
				}
				Iterator<?> iter = lengthsObj.keys();
				while (iter.hasNext()) {
					String key = (String)iter.next();
					int p = Integer.parseInt(key);
					periodLengths[p] = lengthsObj.getInt(key);
				}
			}
			if (hasBreak) {
				periodsBeforeBreak = obj.getInt("periodsBeforeBreak");
				periodsAfterBreak = obj.getInt("periodsAfterBreak");
				breakLength = obj.getInt("breakLength");
				breakName = obj.getString("breakName");
				breakIsFree = obj.optBoolean("breakIsFree");
			} else {
				periodsBeforeBreak = numPeriods;
				periodsAfterBreak = 0;
			}
		} catch (JSONException ignored) {}
		periods = new ArrayList<Period>();
	}
	
	public void fillPeriods(Curriculum c) {
		Course[] courseList = c.getCourseList(date);
		periods = new ArrayList<Period>(numPeriods+1);
		Time nextStart = c.getDayStartTime();
		int index = 0;
		
		//add periods before break
		for (int num=1; num<=periodsBeforeBreak; num++) {
			Course course = courseList[num];
			int duration = periodLength;
			if (periodLengths != null && periodLengths[num] >= 0) duration = periodLengths[num];
			if (course==null) periods.add(new Period("X", date, nextStart, nextStart.timeByAdding(duration), num, index, true));
			else periods.add(new Period(course.getName(), date, nextStart, nextStart.timeByAdding(duration), num, index, false));
			nextStart = nextStart.timeByAdding(duration+c.getPassingPeriodLength());
			index++;
		}
		
		if (hasBreak) {
			//add break
			periods.add(new Period(breakName, date, nextStart, nextStart.timeByAdding(breakLength), 0, index, breakIsFree));
			nextStart = nextStart.timeByAdding(breakLength+c.getPassingPeriodLength());
			index++;
		}
		
		//add periods after break
		for (int num=periodsBeforeBreak+1; num<=periodsBeforeBreak+periodsAfterBreak; num++) {
			Course course = courseList[num];
			int duration = periodLength;
			if (periodLengths != null && periodLengths[num] >= 0) duration = periodLengths[num];
			if (course==null) periods.add(new Period("X", date, nextStart, nextStart.timeByAdding(duration), num, index, true));
			else periods.add(new Period(course.getName(), date, nextStart, nextStart.timeByAdding(duration), num, index, false));
			nextStart = nextStart.timeByAdding(duration+c.getPassingPeriodLength());
			index++;
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
				obj.put("breakIsFree", breakIsFree);
			}
		} catch (JSONException ignored) {}
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
