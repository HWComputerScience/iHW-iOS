package general;

import java.util.*;

import model.Course;
import model.Curriculum;
import model.Day;
import view.*;

public class Controller implements ScheduleViewDelegate, ScheduleViewDataSource {
	
	private Curriculum currentCurriculum; //Brandon's first commit
	
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
		CoursesFrame cframe = new CoursesFrame(currentCurriculum.getAllCourseNames(), 5,8);
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

	public boolean addCourse(Course c) {
		if (currentCurriculum.addCourse(c)) {
			currentCurriculum.rebuildSpecialDays("");
			return true;
		}
		return false;
	}

	public boolean editCourse(String oldName, Course c) {
		Course oldCourse = currentCurriculum.getCourse(oldName);
		currentCurriculum.removeCourse(oldCourse);
		if (currentCurriculum.addCourse(c)) {
			currentCurriculum.rebuildSpecialDays("");
			return true;
		} else {
			currentCurriculum.addCourse(oldCourse);
			return false;
		}
	}

	public Course getCourse(String name) {
		return currentCurriculum.getCourse(name);
	}
}
