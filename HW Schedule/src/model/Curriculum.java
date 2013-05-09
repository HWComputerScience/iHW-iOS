package model;

import java.util.*;

/**
 * The Curriculum class is the top-level class in the model. It represents one school year of classes.
 */
public class Curriculum {
	public static final int TERM_FULL_YEAR        = 0;
	public static final int TERM_FIRST_SEMESTER   = 1;
	public static final int TERM_SECOND_SEMESTER  = 2;
	public static final int TERM_FIRST_TRIMESTER  = 3;
	public static final int TERM_SECOND_TRIMESTER = 4;
	public static final int TERM_THIRD_TRIMESTER  = 5;
	
	public static final int CAMPUS_MIDDLE = 6;
	public static final int CAMPUS_UPPER  = 5;
	
	private int campus;
	private Set<Course> courses;
	private Map<Date, Day> specialDays;
	private Map<Date, Map<Integer, List<Note>>> notes; //Integer represents period number
	private int year; //2012 for the 2012-2013 school year, for example
	private Date[] semesterEndDates; //3 values: the first day of the first semester and the last days of both semesters
	private Date[] trimesterEndDates; //4 values: the first day of the first trimester and the last days of all trimesters
	
	/**
	 * Loads a curriculum object from two JSON strings (which are in two different files).
	 * 
	 * The yearJSON string describes all of the unusual days in the year, and
	 * anything else that is not specific to this particular user.
	 * 
	 * The curriculumJSON stores courses, notes, and anything else that is specific
	 * to the user and his/her schedule.
	 */
	public Curriculum(String yearJSON, String curriculumJSON) {
		//TODO: load from JSON strings
		//should call JSON object constructors from other model classes
		//load year, semester/trimester end dates
		//initialize and store courses in set
		//initialize and store special days in map (call rebuildSpecialDays())
		//initialize and store notes in map of maps
	}
	
	/**
	 * When the user has changed his/her courses, the special days need to be reloaded.
	 */
	public void rebuildSpecialDays(String yearJSON) {
		//TODO: initialize and store special days in map
	}
	
	/**
	 * If day is special, return it from the list of special days.
	 * Otherwise generate the day and return it.
	 */
	public Day getDay(Date d) {
		//TODO: search specialDays for this date -- if found, return it
		//If not found, generate a NormalDay
		return null;
	}
	
	public Set<Course> getAllCourses() {
		return courses;
	}
	
	public String saveCurriculum() {
		String json = "";
		//TODO: convert curriculum to a JSON string
		//should call save methods from other model classes
		return json;
	}

	public int getYear() { return year; }
	
	public void setSemesters(Date[] semesterEndDates) {
		this.semesterEndDates = semesterEndDates;
	}
	
	public void setTrimesters(Date[] trimesterEndDates) {
		this.trimesterEndDates = trimesterEndDates;
	}
	
	public boolean addCourse(Course c) {
		//TODO: check for conflicts and return false if necessary
		//take into account class meetings (including double periods) and term
		courses.add(c);
		return true;
	}
	
	public Course getCourse(int term, int period, int dayNum) {
		for (Course c : courses) {
			if (c.getPeriod() == period && c.getMeetingOn(dayNum) >= 0) return c;
		}
		return null;
	}
	
	public List<Note> getNote(Date d, int period) {
		if (notes.containsKey(d)) {
			Map<Integer, List<Note>> notesThisDay = notes.get(d);
			if (notesThisDay.containsKey(period)) {
				return notesThisDay.get(period);
			}
		}
		return new ArrayList<Note>(0);
	}
	
	public void removeCourse(Course c) {
		courses.remove(c);
	}
	
	public static String generateBlankCurriculumJSON() {
		//TODO: Generate a blank, new curriculum JSON string with no courses or notes.
		return "";
	}
}
