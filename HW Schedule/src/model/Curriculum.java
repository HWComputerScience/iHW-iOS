package model;

import java.util.*;

public class Curriculum {
	private List<Course> courses;
	
	public Curriculum() {
		courses = new LinkedList<Course>();
	}
	
	public void addCourse(Course c) {
		//validate...
		courses.add(c);
	}
	
	public ArrayList<Course> getCourses(int period) {
		ArrayList<Course> ret = new ArrayList<Course>();
		for (Course c : courses) {
			if (c.getPeriod() == period) ret.add(c);
		}
		return ret;
	}
	
	public void removeCourse(Course c) {
		courses.remove(c);
	}
}
