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
	
	public static void main(String[] args) {
		//System.out.println(Curriculum.generateBlankYearJSON(Curriculum.CAMPUS_UPPER, 2012));
		
		JSONArray obj = new JSONArray();
		//obj.put(new model.NormalDay(new Date(9,4,2012), null, 1, 0, 8, 40, "Convocation/Investiture", 40).saveDay());
		//obj.put(new model.NormalDay(new Date(1,17,2013), null, 0, 8, 45).saveDay());
		
		/*Period sat = new Period("SAT Reasoning Test & SAT Subject Tests", new Date(10,6,2013), new Time(8,0), new Time(14,30), 1);
		ArrayList<Period> periods = new ArrayList<Period>(1);
		periods.add(sat);
		obj.put(new TestDay(new Date(10,6,2013), periods).saveDay());
		*/
		obj.put(new Note("hello, world!", true).saveNote());
		
		System.out.println(obj.toString(4));
		//new Controller();
	}
	
	public Controller() {
		GregorianCalendar today = new GregorianCalendar();
		int year = today.get(GregorianCalendar.YEAR);
		if (today.get(GregorianCalendar.MONTH) < GregorianCalendar.JULY) year--;
		String campus = (String)JOptionPane.showInputDialog(new JFrame(),
				"Which campus do you attend?", 
				"HW Schedule",
				JOptionPane.QUESTION_MESSAGE,
				null,
				new String[] {"Middle School","Upper School"},
				1);
		if (campus==null) System.exit(0);
		String campusChar = campus.substring(0, 1).toLowerCase();
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
			System.out.println("EXCEPTION while reading curriculum file:");
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
			if (campusChar.equals("u")) {
				yearJSON = Curriculum.generateBlankYearJSON(Curriculum.CAMPUS_UPPER, year);
			} else {
				yearJSON = Curriculum.generateBlankYearJSON(Curriculum.CAMPUS_MIDDLE, year);
			}
			try {
				PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(filename)));
				out.println(yearJSON);
				out.close();
			} catch(IOException e2) {
				System.out.println("EXCEPTION while writing year file.");
			}
		} catch (IOException e) {
			System.out.println("EXCEPTION while reading year file:");
			e.printStackTrace();
			System.exit(1);
		}
		
		currentCurriculum = new Curriculum(curriculumJSON, yearJSON); //should load from file instead
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
		currentCurriculum.rebuildSpecialDays();
	}

	public boolean addCourse(Course c) {
		if (currentCurriculum.addCourse(c)) {
			currentCurriculum.rebuildSpecialDays();
			return true;
		}
		return false;
	}

	public boolean editCourse(String oldName, Course c) {
		Course oldCourse = currentCurriculum.getCourse(oldName);
		currentCurriculum.removeCourse(oldCourse);
		if (currentCurriculum.addCourse(c)) {
			currentCurriculum.rebuildSpecialDays();
			return true;
		} else {
			currentCurriculum.addCourse(oldCourse);
			return false;
		}
	}

	public Course getCourse(String name) {
		return currentCurriculum.getCourse(name);
	}
	
	public void addNote(String text, Date d, int periodNum) {
		// TODO tell the controller that the note was added and refresh the displayed notes
	}
	
	public void replaceNote(String text, String toReplace, Date d, int periodNum) {
		// TODO tell the controller that the note was replaced and refresh the displayed notes
	}
	
	public List<Note> getNotes(Date d, int period) {
		return currentCurriculum.getNotes(d,period);
	}
}
