package model;

import java.util.*;

public class Curriculum {
	private List<Course> courses;
	
	public Curriculum() {
		courses = new LinkedList<Course>();
	}
	
	public void addCourse(Course c) {
		//check for conflicts...
		courses.add(c);
	}
	
	public Course getCourse(int period, int dayNum) {
		for (Course c : courses) {
			if (c.getPeriod() == period && c.getMeetingOn(dayNum) >= 0) return c;
		}
		return null;
	}
	
	public void removeCourse(Course c) {
		courses.remove(c);
	}
}
