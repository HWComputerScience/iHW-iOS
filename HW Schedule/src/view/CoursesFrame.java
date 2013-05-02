package view;

import java.util.*;
import javax.swing.*;
import model.Course;

public class CoursesFrame extends JFrame {
	private static final long serialVersionUID = 6934883684026565042L;
	private Set<Course> courses;

	public CoursesFrame(Set<Course> courses) {
		this.courses = courses;
	}
}
