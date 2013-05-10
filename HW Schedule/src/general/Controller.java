package general;

import java.util.*;

import model.Course;
import model.Curriculum;
import model.Day;
import view.*;

public class Controller implements ScheduleViewDelegate, ScheduleViewDataSource {
	
	private Curriculum currentCurriculum;
	
	public static void main(String[] args) {
		new Controller();
	}
	
	public Controller() {
		currentCurriculum = new Curriculum("",""); //should load from file instead
		showHomepage();
	}
	
	public void showHomepage() {
		new HomepageFrame().setDelegate(this);
	}

	public void showCourseEditor() {
		CoursesFrame cframe = new CoursesFrame(currentCurriculum.getAllCourseNames(), 8,5);
		cframe.setDelegate(this);
		cframe.setDataSource(this);
		//some other stuff
	}

	public void showSchedule() {
		ScheduleFrame frame = new ScheduleFrame();
		frame.setDelegate(this);
		frame.setDataSource(this);
		//some other stuff
	}

	public Day getDay(Date d) {
		return currentCurriculum.getDay(d);
	}

	public void deleteCourse(String name) {
		currentCurriculum.removeCourse(currentCurriculum.getCourse(name));
		currentCurriculum.rebuildSpecialDays("");
	}

	public void addCourse(Course c) {
		currentCurriculum.addCourse(c);
		currentCurriculum.rebuildSpecialDays("");
	}

	public void editCourse(String oldName, Course c) {
		currentCurriculum.removeCourse(currentCurriculum.getCourse(oldName));
		currentCurriculum.addCourse(c);
		currentCurriculum.rebuildSpecialDays("");
	}

	public Course getCourse(String name) {
		return currentCurriculum.getCourse(name);
	}
}
