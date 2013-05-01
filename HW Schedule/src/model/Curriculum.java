package model;

import java.util.*;

/**
 * The Curriculum class is the top-level class in the model. It represents a year of classes.
 */
public class Curriculum {
	public static final int TERM_FULL_YEAR        = 0;
	public static final int TERM_FIRST_SEMESTER   = 1;
	public static final int TERM_SECOND_SEMESTER  = 2;
	public static final int TERM_FIRST_TRIMESTER  = 3;
	public static final int TERM_SECOND_TRIMESTER = 4;
	public static final int TERM_THIRD_TRIMESTER  = 5;
	
	private Set<Course> courses;
	private int year; //2012 for the 2012-2013 school year, for example
	private Date[] semesterEndDates; //3 values: the first day of the first semester and the last days of both semesters
	private Date[] trimesterEndDates; //4 values: the first day of the first trimester and the last days of all trimesters
	
	public Curriculum(int year) {
		this.year = year;
		courses = new HashSet<Course>();
	}

	public int getYear() { return year; }
	
	public void setSemesters(Date[] semesterEndDates) {
		this.semesterEndDates = semesterEndDates;
	}
	
	public void setTrimesters(Date[] trimesterEndDates) {
		this.trimesterEndDates = trimesterEndDates;
	}
	
	public void addCourse(Course c) {
		//check for conflicts...
		courses.add(c);
	}
	
	public Course getCourse(int term, int period, int dayNum) {
		for (Course c : courses) {
			if (c.getPeriod() == period && c.getMeetingOn(dayNum) >= 0) return c;
		}
		return null;
	}
	
	public void removeCourse(Course c) {
		courses.remove(c);
	}
	
	public static boolean dateInTerm(int term, Date date) {
		if (term==0) return true;
		//some fancy stuff
		return false;
	}
}
