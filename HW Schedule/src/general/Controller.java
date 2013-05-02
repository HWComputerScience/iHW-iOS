package general;

import model.Curriculum;
import view.*;

public class Controller implements ScheduleViewDelegate {
	
	private Curriculum currentCurriculum;
	
	public static void main(String[] args) {
		new Controller();
	}
	
	public Controller() {
		currentCurriculum = new Curriculum(2012); //should load from file instead
		showHomepage();
	}
	
	public void showHomepage() {
		new HomepageFrame();
	}

	public void showCourseEditor() {
		new CoursesFrame(currentCurriculum.getAllCourses());
		//some other stuff
	}

	public void showSchedule() {
		new ScheduleFrame();
		//some other stuff
	}
}
