package general;

import java.io.*;
import java.util.*;
import javax.swing.*;
import org.json.*;

import model.*;
import model.Date;
import view.*;

public class Controller implements ScheduleViewDelegate, ScheduleViewDataSource {
	
	private Curriculum currentCurriculum;
	private int campus;
	private CoursesFrame cframe;
	private ScheduleFrame sframe;
	
	public static void main(String[] args) {
		//System.out.println(Curriculum.generateBlankYearJSON(Curriculum.CAMPUS_UPPER, 2012));
		
		//JSONArray obj = new JSONArray();
		//obj.put(new model.NormalDay(new Date(9,4,2012), null, 0, 2, 6, 30, "Activities", 45).saveDay());
		//obj.put(new model.NormalDay(new Date(1,17,2013), null, 0, 8, 45).saveDay());
		
		/*Period sat = new Period("SAT Reasoning Test & SAT Subject Tests", new Date(10,6,2013), new Time(8,0), new Time(14,30), 1);
		ArrayList<Period> periods = new ArrayList<Period>(1);
		periods.add(sat);
		obj.put(new TestDay(new Date(10,6,2013), periods).saveDay());
		*/
		//obj.put(new Note("hello, world!", true).saveNote());
		/*
		obj.put(new Course("Symphony", 1, Curriculum.TERM_FULL_YEAR,
				new int[] {
					Course.MEETING_DOUBLE_AFTER,
					Course.MEETING_X_DAY,
					Course.MEETING_SINGLE_PERIOD,
					Course.MEETING_X_DAY,
					Course.MEETING_SINGLE_PERIOD
				}).saveCourse());
		*/
		//System.out.println(obj.toString(4));
		new Controller();
	}
	
	public Controller() {
		GregorianCalendar today = new GregorianCalendar();
		int year = today.get(GregorianCalendar.YEAR);
		if (today.get(GregorianCalendar.MONTH) < GregorianCalendar.JULY) year--;
		String campusStr = (String)JOptionPane.showInputDialog(new JFrame(),
				"Which campus do you attend?", 
				"HW Schedule",
				JOptionPane.QUESTION_MESSAGE,
				null,
				new String[] {"Middle School","Upper School"},
				"Upper School");
		if (campusStr==null) System.exit(0);
		String campusChar = campusStr.substring(0, 1).toLowerCase();
		if (campusChar.equals("u")) campus = Curriculum.CAMPUS_UPPER;
		else campus = Curriculum.CAMPUS_MIDDLE;
		String curriculumJSON = "";
		String filename = "schooldata/curriculum" + year + campusChar + ".hws";
		try {
			BufferedReader f = new BufferedReader(new FileReader(filename));
			String line = f.readLine();
			while (line != null) {
				curriculumJSON += line + "\n";
				line=f.readLine();
			}
			f.close();
		} catch (FileNotFoundException e) {
			JOptionPane.showMessageDialog(new JFrame(), "Sorry, the curriculum file \"" + filename + "\" was not found for the selected campus and current year.", "HW Schedule",JOptionPane.ERROR_MESSAGE);
			System.exit(0);
		} catch (IOException e) {
			System.err.println("EXCEPTION while reading curriculum file:");
			e.printStackTrace();
			System.exit(1);
		}
		
		String yearJSON = "";
		filename = "userdata/year" + year + campusChar + ".hws";
		try {
			BufferedReader f = new BufferedReader(new FileReader(filename));
			String line = f.readLine();
			while (line != null) {
				yearJSON += line + "\n";
				line=f.readLine();
			}
			f.close();
		} catch (FileNotFoundException e) {
			yearJSON = Curriculum.generateBlankYearJSON(campus, year);
			try {
				PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(filename)));
				out.println(yearJSON);
				out.close();
			} catch(IOException e2) {
				System.err.println("EXCEPTION while writing year file.");
			}
		} catch (IOException e) {
			System.err.println("EXCEPTION while reading year file:");
			e.printStackTrace();
			System.exit(1);
		}
		
		currentCurriculum = new Curriculum(curriculumJSON, yearJSON);
		//System.out.println(currentCurriculum.getDay(new Date(9,3,2012)).saveDay());
		showHomepage();
	}
	
	public void showHomepage() {
		new HomepageFrame().setDelegate(this);
	}

	public void showCourseEditor() {
		cframe = new CoursesFrame(campus, campus+3);
		cframe.setDelegate(this);
		cframe.setDataSource(this);
		cframe.regenerateListItems(currentCurriculum.getAllCourseNames());
		//some other stuff
	}

	public void showSchedule() {
		sframe = new ScheduleFrame();
		sframe.setDelegate(this);
		sframe.setDataSource(this);
		sframe.loadDayRange(new Date(9,3,2012), new Date(9,7,2012));
	}

	public Day getDay(Date d) {
		return currentCurriculum.getDay(d);
	}

	public void deleteCourse(String name) {
		currentCurriculum.removeCourse(currentCurriculum.getCourse(name));
		if (cframe!=null) cframe.regenerateListItems(currentCurriculum.getAllCourseNames());
	}

	public boolean addCourse(Course c) {
		if (currentCurriculum.addCourse(c)) {
			if (cframe!=null) cframe.regenerateListItems(currentCurriculum.getAllCourseNames());
			return true;
		}
		return false;
	}

	public boolean editCourse(String oldName, Course c) {
		Course oldCourse = currentCurriculum.getCourse(oldName);
		currentCurriculum.removeCourse(oldCourse);
		if (currentCurriculum.addCourse(c)) {
			if (cframe!=null) cframe.regenerateListItems(currentCurriculum.getAllCourseNames());
			return true;
		} else {
			currentCurriculum.addCourse(oldCourse);
			if (cframe!=null) cframe.regenerateListItems(currentCurriculum.getAllCourseNames());
			return false;
		}
	}

	public Course getCourse(String name) {
		return currentCurriculum.getCourse(name);
	}
	
	public void addNote(String text, boolean isToDo, Date d, int periodNum) {
		currentCurriculum.addNote(text, isToDo, false, d, periodNum);
		sframe.loadDayRange(sframe.getDateRange()[0], sframe.getDateRange()[1]);
	}
	
	public void replaceNote(String text, boolean isToDo, String toReplace, Date d, int periodNum) {
		Note old = currentCurriculum.removeNote(d, periodNum, toReplace);
		boolean checked = false;
		if (old != null) checked=old.isChecked();
		currentCurriculum.addNote(text, isToDo, checked, d, periodNum);
		sframe.loadDayRange(sframe.getDateRange()[0], sframe.getDateRange()[1]);
	}
	
	public List<Note> getNotes(Date d, int period) {
		return currentCurriculum.getNotes(d,period);
	}
}
