package general;

import java.util.*;

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
		new CoursesFrame(currentCurriculum.getAllCourses());
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
}
