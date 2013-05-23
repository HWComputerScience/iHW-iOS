package model;

import java.util.*;
import org.json.*;

public class NormalDay extends Day {
	private int dayNumber;
	private boolean hasBreak;
	private int periodLength;
	private Time breakEnd;
	private String breakName;
	
	/**
	 * Used to initialize a normal day that has an activities period or assembly.
	 */
	public NormalDay(Date d, 
					 Curriculum c, 
					 int[] terms,
					 int dayNum, 
					 int periodsBeforeBreak, 
					 int periodsAfterBreak, 
					 Time breakEnd, 
					 String breakName, 
					 int pLength) {
		this.breakEnd=breakEnd;
		this.breakName=breakName;
		date = d;
		hasBreak = true;
		periodLength = pLength;
		periods = new ArrayList<Period>(periodsBeforeBreak+periodsAfterBreak+1);
		for (int i=1; i<=periodsBeforeBreak; i++) {
			//ArrayList<Course> courses = c.getCourses(i);
			//TODO: add the periods in this day up to the break
		}
		//TODO: Add break as a period
		for (int i=periodsBeforeBreak+1; i<=periodsAfterBreak; i++) {
			//ArrayList<Course> courses = c.getCourses(i);
			//TODO: add the periods in this day after the break
		}
	}
	
	/**
	 * Used to initialize a normal day that does not have an activities period or assembly.
	 */
	public NormalDay(Date d, Curriculum c, int dayNum, int numPeriods, int pLength) {
		date = d;
		hasBreak = false;
		periodLength = pLength;
		periods = new ArrayList<Period>(numPeriods);
		for (int i=1; i<=numPeriods; i++) {
			//ArrayList<Course> courses = c.getCourses(i);
			//TODO: add the periods in this day
		}
	}
	
	public NormalDay(JSONObject obj, Curriculum c) {
		//TODO: load from JSON object
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
		obj.put("type", "normal");
		obj.put("dayNumber", dayNumber);
		obj.put("hasBreak", hasBreak);
		obj.put("periodLength", periodLength);
		if (hasBreak) {
			obj.put("breakEnd", breakEnd);
			obj.put("breakName", breakName);
		}
		return obj;
	}
	
	public int getDayNumber() { return dayNumber; }
	public boolean hasBreak() { return hasBreak; }
	public int getPeriodLength() { return periodLength; }
}
