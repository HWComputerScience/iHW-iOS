package view;

import java.util.*;
import model.Course;
import model.Day;

public interface ScheduleViewDelegate {
	void showCourseEditor();
	void showSchedule();
	void deleteCourse(String name);
	boolean addCourse(Course c);
	boolean editCourse(String oldName, Course c);
}
