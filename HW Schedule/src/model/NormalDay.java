package model;

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
		
		if (c!=null) fillPeriods(c); 
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
		
		if (c!= null) fillPeriods(c);
	}
	
	public NormalDay(JSONObject obj, Curriculum c) {
		super(obj);
		dayNumber = obj.getInt("dayNumber");
		hasBreak = obj.getBoolean("hasBreak");
		periodLength = obj.getInt("periodLength");
		numPeriods = obj.getInt("numPeriods");
		if (hasBreak) {
			periodsBeforeBreak = obj.getInt("periodsBeforeBreak");
			periodsAfterBreak = obj.getInt("periodsAfterBreak");
			breakLength = obj.getInt("breakLength");
			breakName = obj.getString("breakName");
		}
		if (c!=null) fillPeriods(c);
	}
	
	public void fillPeriods(Curriculum c) {
		if (hasBreak) {
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
		} else {
			periods = new ArrayList<Period>(numPeriods);
			for (int i=1; i<=numPeriods; i++) {
				//ArrayList<Course> courses = c.getCourses(i);
				//TODO: add the periods in this day
			}
		}
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
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
		return obj;
	}
	
	public int getDayNumber() { return dayNumber; }
	public boolean hasBreak() { return hasBreak; }
	public int getPeriodLength() { return periodLength; }
}
