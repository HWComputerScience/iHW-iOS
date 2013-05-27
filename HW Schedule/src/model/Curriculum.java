package model;

import java.util.*;

import org.json.*;

/**
 * The Curriculum class is the top-level class in the model.
 * It represents one school year of classes and notes.
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
	private JSONObject normalDayTemplate;
	private JSONObject normalMondayTemplate;
	private int passingPeriodLength;
	private Map<Date, Day> specialDays;
	private Map<Date, Integer> dayNumbers;
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
		normalDayTemplate = curriculumObj.getJSONObject("normalDay");
		normalMondayTemplate = curriculumObj.getJSONObject("normalMonday");
		passingPeriodLength = curriculumObj.getInt("passingPeriodLength");
		
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
			if (dayObj.getString("type").equals("normal")) toAdd = new NormalDay(dayObj);
			else if (dayObj.getString("type").equals("test")) toAdd = new TestDay(dayObj);
			else if (dayObj.getString("type").equals("holiday")) toAdd = new Holiday(dayObj);
			else throw new IllegalStateException("Unrecognized day type found in curriculum.");
			Date d = new Date(dayObj.getString("date"));
			specialDays.put(d, toAdd);
		}
		//initialize day numbers
		dayNumbers = new TreeMap<Date, Integer>();
		Date d = semesterEndDates[0];
		int dayNum = 1;
		while(d.compareTo(semesterEndDates[2]) < 0) {
			if (specialDays.get(d) != null) {
				if (specialDays.get(d) instanceof NormalDay && ((NormalDay)specialDays.get(d)).getDayNumber()!=0) {
					//This special day has a number; continue the count from this day's daynum
					dayNumbers.put(d, ((NormalDay)specialDays.get(d)).getDayNumber());
					dayNum = ((NormalDay)specialDays.get(d)).getDayNumber() + 1;
				} else {
					//This special day doesn't have a day number; set this daynum to 0 and don't increment
					dayNumbers.put(d, 0);
				}
			} else {
				//This is a normal day; continue the count
				if (!d.isWeekend()) {
					dayNumbers.put(d, dayNum);
					dayNum++;
				}
			}
			if (dayNum>campus) dayNum -= campus;
			d=d.dateByAdding(1);
		}
		
		rebuildSpecialDays();
		
		//initialize and store notes in map of maps
		JSONArray notesArr = yearObj.getJSONArray("notes");
		notes = new TreeMap<Date, TreeMap<Integer,List<Note>>>();
		for (int i=0; i<notesArr.length(); i++) {
			JSONObject obj = notesArr.getJSONObject(i);
			d = new Date(obj.getString("date"));
			int period = obj.getInt("period");
			String text = obj.getString("text");
			boolean isToDo = obj.getBoolean("isToDo");
			this.addNote(text, isToDo, d, period);
		}
	}
	
	/**
	 * When the user has changed his/her courses, the special days need to be reloaded.
	 */
	public void rebuildSpecialDays() {
		for (Date d : specialDays.keySet()) {
			Day day = specialDays.get(d);
			if (day instanceof NormalDay) {
				((NormalDay)day).fillPeriods(this);
			}
		}
	}
	
	/**
	 * If day is special, return it from the list of special days.
	 * Otherwise generate the day and return it.
	 */
	public Day getDay(Date d) {
		if (specialDays.containsKey(d)) return specialDays.get(d);
		else if (d.isWeekend() ||
				d.compareTo(semesterEndDates[0]) < 0 ||
				d.compareTo(semesterEndDates[2]) > 0) return new Holiday(d, "");
		else if (d.isMonday()) {
			JSONObject dayObj = new JSONObject(normalMondayTemplate, JSONObject.getNames(normalMondayTemplate));
			dayObj.put("date", d.toString());
			dayObj.put("dayNumber", dayNumbers.get(d));
			NormalDay ret = new NormalDay(dayObj);
			ret.fillPeriods(this);
			return ret;
		} else {
			JSONObject dayObj = new JSONObject(normalDayTemplate, JSONObject.getNames(normalDayTemplate));
			dayObj.put("date", d.toString());
			dayObj.put("dayNumber", dayNumbers.get(d));
			NormalDay ret = new NormalDay(dayObj);
			ret.fillPeriods(this);
			return ret;
		}
	}
	
	public List<String> getAllCourseNames() {
		List<String> list = new ArrayList<String>();
		for (Course c : courses) list.add(c.getName());
		return list;
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
	
	/**
	 * Attempts to add the specified course to the curriculum.
	 * Returns true if it was added, and false if scheduling conflicts prevented it from being added.
	 */
	public boolean addCourse(Course c) {
		for (Course check : courses) {
			if (!termsCompatible(c.getTerm(), check.getTerm())) {
				if (c.getPeriod()==check.getPeriod()) {
					for (int i=1; i<=campus; i++) {
						if (c.getMeetingOn(i) != Course.MEETING_X_DAY &&
								check.getMeetingOn(i) != Course.MEETING_X_DAY) return false;
					}
				} else if (Math.abs(c.getPeriod()-check.getPeriod()) == 1) {
					Course later, earlier;
					if (c.getPeriod() > check.getPeriod()) {
						later = c;
						earlier = check;
					} else {
						later = check;
						earlier = c;
					}
					for (int i=1; i<=campus; i++) {
						if (earlier.getMeetingOn(i) == Course.MEETING_DOUBLE_AFTER &&
								later.getMeetingOn(i) != Course.MEETING_X_DAY) return false;
						if (later.getMeetingOn(i) == Course.MEETING_DOUBLE_BEFORE &&
								earlier.getMeetingOn(i) != Course.MEETING_X_DAY) return false;
					}
				} else if (Math.abs(c.getPeriod()-check.getPeriod()) == 2) {
					Course later, earlier;
					if (c.getPeriod() > check.getPeriod()) {
						later = c;
						earlier = check;
					} else {
						later = check;
						earlier = c;
					}
					for (int i=1; i<=campus; i++) {
						if (earlier.getMeetingOn(i) == Course.MEETING_DOUBLE_AFTER &&
								later.getMeetingOn(i) == Course.MEETING_DOUBLE_BEFORE) return false;
					}
				}
			}
		}
		courses.add(c);
		return true;
	}
	
	/**
	 * Returns true when two classes scheduled for terms a and b can coexist regardless
	 * of whether their periods conflict or not.
	 */
	private static boolean termsCompatible(int a, int b) {
		if (a==b) return false;
		if (a==TERM_FULL_YEAR || b==TERM_FULL_YEAR) return false;
		if (a==TERM_FIRST_SEMESTER) {
			if (b==TERM_FIRST_TRIMESTER || b==TERM_SECOND_TRIMESTER) return false;
		} else if (a==TERM_SECOND_SEMESTER) {
			if (b==TERM_SECOND_TRIMESTER || b==TERM_THIRD_TRIMESTER) return false;
		}
		if (b==TERM_FIRST_SEMESTER) {
			if (a==TERM_FIRST_TRIMESTER || a==TERM_SECOND_TRIMESTER) return false;
		} else if (b==TERM_SECOND_SEMESTER) {
			if (a==TERM_SECOND_TRIMESTER || a==TERM_THIRD_TRIMESTER) return false;
		}
		return true;
	}
	
	public List<Integer> termsFromDate(Date d) {
		List<Integer> list = new ArrayList<Integer>(3);
		if (d.compareTo(semesterEndDates[0]) >= 0) {
			if (d.compareTo(semesterEndDates[1]) <= 0) {
				list.add(TERM_FULL_YEAR);
				list.add(TERM_FIRST_SEMESTER);
			} else if (d.compareTo(semesterEndDates[2]) <= 0) {
				list.add(TERM_FULL_YEAR);
				list.add(TERM_SECOND_SEMESTER);
			}
		}
		if (d.compareTo(trimesterEndDates[0]) >= 0) {
			if (d.compareTo(trimesterEndDates[1]) <= 0) list.add(TERM_FIRST_TRIMESTER);
			else if (d.compareTo(trimesterEndDates[2]) <= 0) list.add(TERM_SECOND_TRIMESTER);
			else if (d.compareTo(trimesterEndDates[3]) <= 0) list.add(TERM_THIRD_TRIMESTER);
		}
		return list;
	}
	
	public Course getCourse(Date d, int period) {
		if (d.compareTo(semesterEndDates[0]) < 0 || d.compareTo(semesterEndDates[2]) > 0) return null;
		int dayNum = dayNumbers.get(d);
		List<Integer> terms = termsFromDate(d);
		for (Course c : courses) {
			boolean termFound = false;
			for (int term : terms) {
				if (term==c.getTerm()) {
					termFound = true;
					break;
				}
			}
			if (!termFound) continue;
			if (dayNum==0) {
				if (c.getPeriod()==period) return c;
				continue;
			}
			if (c.getPeriod()==period) {
				if (dayNum==0) return c;
				if (c.getMeetingOn(dayNum) != Course.MEETING_X_DAY) return c; 
			} else if (period == c.getPeriod()-1) {
				if (c.getMeetingOn(dayNum) == Course.MEETING_DOUBLE_BEFORE) return c;
			} else if (period == c.getPeriod()+1) {
				if (c.getMeetingOn(dayNum) == Course.MEETING_DOUBLE_AFTER) return c;
			}
		}
		return null;
	}
	
	public Course getCourse(String name) {
		for (Course c : courses) if (c.getName().equals(name)) return c;
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
	
	public void addNote(String text, boolean isToDo, Date d, int period)
	{
		Note toAdd = new Note(text, isToDo);
		if (notes.get(d) == null) {
			List<Note> list = new LinkedList<Note>();
			list.add(toAdd);
			TreeMap<Integer, List<Note>> inner = new TreeMap<Integer, List<Note>>();
			inner.put(period, list);
			notes.put(d, inner);
		} else if (notes.get(d).get(period) == null) {
			List<Note> list = new LinkedList<Note>();
			list.add(toAdd);
			notes.get(d).put(period, list);
		} else {
			notes.get(d).get(period).add(toAdd);
		}
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

	public int getPassingPeriodLength() { return passingPeriodLength; }
}
