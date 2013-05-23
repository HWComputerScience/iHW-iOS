package view;

import model.Date;
import model.Course;

public interface ScheduleViewDelegate {
	void showCourseEditor();
	void showSchedule();
	void deleteCourse(String name);
	boolean addCourse(Course c);
	boolean editCourse(String oldName, Course c);
	void addNote(String newNote, Date d, int periodNum);
	void replaceNote(String newText, String existingText, Date d, int periodNum);
}
