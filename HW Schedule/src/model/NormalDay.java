package model;

import java.util.*;

import org.json.*;

public class NormalDay extends Day {
	private int dayNumber;
	private boolean hasBreak;
	private int periodLength;
	
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
		date = d;
		hasBreak = true;
		periodLength = pLength;
		periods = new Period[periodsBeforeBreak+periodsAfterBreak+1];
		for (int i=1; i<=periodsBeforeBreak; i++) {
			//ArrayList<Course> courses = c.getCourses(i);
			//initialize the periods in this day
		}
	}
	
	/**
	 * Used to initialize a normal day that does not have an activities period or assembly.
	 */
	public NormalDay(Date d, Curriculum c, int dayNum, int numPeriods, int pLength) {
		date = d;
		hasBreak = false;
		periodLength = pLength;
		periods = new Period[numPeriods];
	}
	
	public NormalDay(JSONObject obj) {
		//load from JSON object
	}
	
	public int getDayNumber() { return dayNumber; }
	public boolean hasBreak() { return hasBreak; }
	public int getPeriodLength() { return periodLength; }
}
