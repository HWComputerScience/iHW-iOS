package view;

import java.util.*;
import model.Course;
import model.Day;

public interface ScheduleViewDelegate {
	void showCourseEditor();
	void showSchedule();
	void deleteCourse(String name);
	void addCourse(Course c);
	void editCourse(String oldName, Course c);
}
