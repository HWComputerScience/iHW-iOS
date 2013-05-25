package model;

import java.util.*;

import org.json.*;

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
	private TreeMap<Date, TreeMap<Integer, List<Note>>> notes; //Integer represents period number
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
	public Curriculum(String curriculumJSON, String yearJSON) {
		JSONObject curriculumObj = new JSONObject(curriculumJSON);
		JSONObject yearObj = new JSONObject(yearJSON);
		
		//load year, semester/trimester end dates, etc.
		year = curriculumObj.getInt("year");
		campus = curriculumObj.getInt("campus");
		JSONArray semestersArr = curriculumObj.getJSONArray("semesterEndDates");
		semesterEndDates = new Date[semestersArr.length()];
		for (int i=0; i<semestersArr.length(); i++) {
			semesterEndDates[i] = new Date(semestersArr.getString(i));
		}
		JSONArray trimestersArr = curriculumObj.getJSONArray("trimesterEndDates");
		trimesterEndDates = new Date[trimestersArr.length()];
		for (int i=0; i<trimestersArr.length(); i++) {
			trimesterEndDates[i] = new Date(trimestersArr.getString(i));
		}
		
		//initialize and store courses in set
		JSONArray coursesArr = yearObj.getJSONArray("courses");
		courses = new HashSet<Course>(coursesArr.length());
		for (int i=0; i<coursesArr.length(); i++) {
			courses.add(new Course(coursesArr.getJSONObject(i)));
		}
		
		//initialize and store special days in map
		JSONArray specialDaysArr = curriculumObj.getJSONArray("specialDays");
		specialDays = new TreeMap<Date, Day>();
		for (int i=0; i<specialDaysArr.length(); i++) {
			JSONObject dayObj = specialDaysArr.getJSONObject(i);
			Day toAdd = null;
			if (dayObj.getString("type").equals("normal")) toAdd = new NormalDay(dayObj, this);
			else if (dayObj.getString("type").equals("test")) toAdd = new TestDay(dayObj);
			else if (dayObj.getString("type").equals("holiday")) toAdd = new Holiday(dayObj);
			else throw new IllegalStateException("Unrecognized day type found in curriculum.");
			Date d = new Date(dayObj.getString("date"));
			specialDays.put(d, toAdd);
		}
		
		//initialize and store notes in map of maps
		JSONArray notesArr = yearObj.getJSONArray("notes");
		notes = new TreeMap<Date, TreeMap<Integer,List<Note>>>();
		for (int i=0; i<notesArr.length(); i++) {
			
		}
	}
	
	/**
	 * When the user has changed his/her courses, the special days need to be reloaded.
	 */
	public void rebuildSpecialDays() {
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
	
	public List<String> getAllCourseNames() {
		//TODO: make this method return a list of course names
		return new ArrayList<String>();
	}
	
	public String saveYear() {
		JSONObject obj = new JSONObject();
		obj.put("year", this.year);
		obj.put("campus", this.campus);
		
		JSONArray coursesArr = new JSONArray();
		for (Course c : courses) {
			coursesArr.put(c.saveCourse());
		}
		obj.put("courses", coursesArr);
		
		JSONArray notesArr = new JSONArray();
		JSONObject note;
		for (Date d : notes.keySet())
		  for (int period : notes.get(d).keySet())
		  for (Note n : notes.get(d).get(period)) {
			note = n.saveNote();
			note.put("date", d);
			note.put("period", period);
			notesArr.put(note);
		}
		obj.put("notes", notesArr);
		return obj.toString(4);
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
	
	public Course getCourse(String name) {
		//TODO: get course by name
		return null;
	}
	
	public List<Note> getNotes(Date d, int period) {
		if (notes.containsKey(d)) {
			Map<Integer, List<Note>> notesThisDay = notes.get(d);
			if (notesThisDay.containsKey(period)) {
				return notesThisDay.get(period);
			}
		}
		return new ArrayList<Note>(0);
	}
	
	public void addNote (String text, Date d, int period)
	{
		//notes.put(d, new Map(period,new List(text))); // wrong and causes errors
		//TODO: fix it
	}
	
	public void removeCourse(Course c) {
		courses.remove(c);
	}
	
	/**
	 * Generates a blank, new year JSON string with no courses or notes.
	 */
	public static String generateBlankYearJSON(int campus, int year) {
		JSONObject obj = new JSONObject();
		obj.put("year", year);
		obj.put("campus", campus);
		obj.put("courses", new JSONArray());
		obj.put("notes", new JSONArray());
		return obj.toString(4);
	}
}
