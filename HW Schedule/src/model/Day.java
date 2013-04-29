package model;

import java.util.*;

public class Day {
	private Date date;
	private int dayNumber;
	private boolean hasBreak;
	private int periodLength;
	
	private Period[] periods;
	
	public Day(Date d, Curriculum c, int dayNum, int periodsBeforeBreak, int periodsAfterBreak, Time breakEnd, String breakName, int pLength) {
		date = d;
		hasBreak = true;
		periodLength = pLength;
		periods = new Period[periodsBeforeBreak+periodsAfterBreak+1];
		for (int i=1; i<=periodsBeforeBreak; i++) {
			ArrayList<Course> courses = c.getCourses(i);
			
		}
	}
	
	public Day(Date d, Curriculum c, int dayNum, int numPeriods, int pLength) {
		date = d;
		hasBreak = false;
		periodLength = pLength;
		periods = new Period[numPeriods];
	}
	
	public Date getDate() { return date; }
}
