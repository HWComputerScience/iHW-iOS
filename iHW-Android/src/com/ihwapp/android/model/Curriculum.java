package com.ihwapp.android.model;

import java.util.*;

import android.app.AlertDialog;
import android.content.*;
import android.net.*;
import android.util.Log;

import com.ihwapp.android.Constants;
import com.ihwapp.android.LaunchActivity;
import com.ihwapp.android.R;

import org.json.*;

/**
 * The Curriculum class is the top-level class in the model.
 * It represents one school year of classes and notes.
 */
public class Curriculum {
	
	private static Curriculum currentCurriculum;
	
	public static Curriculum getCurrentCurriculum(Context ctx) {
		return getCurriculum(ctx, getCurrentCampus(ctx), getCurrentYear(ctx));
	}
	
	public static boolean loadCurrentCurriculum(Context ctx) {
		return loadCurriculum(ctx, getCurrentCampus(ctx), getCurrentYear(ctx));
	}
	
	public static boolean reloadCurrentCurriculum(Context ctx) {
		return downloadCurriculumJSON(ctx, getCurrentCampus(ctx), getCurrentYear(ctx), false);
	}
	
	/*
	 * Returns the curriculum specified by campus and year. If that curriculum is not ready yet,
	 * attempts to load it immediately. If it cannot be loaded immediately, returns null.
	 */
	public static Curriculum getCurriculum(Context ctx, int campus, int year) {
		if (loadCurriculum(ctx, campus, year)) return currentCurriculum;
		else return null;
	}
	
	/*
	 * Loads the curriculum specified by campus and year. If that curriculum is already loaded, does nothing.
	 * Returns whether, after the calling of this method, the curriculum is ready to use.
	 * (The curriculum would not be ready to use if a download from the server is necessary first)
	 */
	public static boolean loadCurriculum(final Context ctx, final int campus, final int year) {
		if (currentCurriculum != null 
				&& currentCurriculum.getYear() == year
				&& currentCurriculum.getCampus() == campus) return true;
		String campusChar = null;
		if (campus==Constants.CAMPUS_MIDDLE) campusChar="m";
		else if (campus==Constants.CAMPUS_UPPER) campusChar = "u";
		SharedPreferences prefs = ctx.getSharedPreferences(year + campusChar, Context.MODE_PRIVATE);
		String curriculumJSON =  prefs.getString("curriculumJSON", "");
		if (curriculumJSON == "") {
			if (!downloadCurriculumJSON(ctx, campus, year, true)) {
				new AlertDialog.Builder(ctx, R.style.PopupTheme).setMessage("iHW requires internet access when running for the first time. Please try again later when you are connected to a Wi-Fi or cellular network.")
				.setPositiveButton("Cancel", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						Intent i = new Intent(ctx, LaunchActivity.class);
						ctx.startActivity(i);
					}
				})
				.setNegativeButton("Retry", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int which) {
						loadCurriculum(ctx, campus, year);
					}
				}).show();
			}
			return false;
		} else {
			String yearJSON = prefs.getString("yearJSON", generateBlankYearJSON(campus, year));
			//Log.d("iHW", yearJSON);
			currentCurriculum = new Curriculum(curriculumJSON, yearJSON);
			return true;
		}
		
	}
	
	/*
	 * Downloads an updated current curriculum JSON from the server. Returns false if there is no Internet connection.
	 */
	public static boolean downloadCurriculumJSON(final Context ctx, final int campus, final int year, boolean isImportant) {
		ConnectivityManager connMgr = (ConnectivityManager)ctx.getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo networkInfo = connMgr.getActiveNetworkInfo();
	    if (networkInfo == null || !networkInfo.isConnected()) {
	    	return false;
	    }
		String campusChar = null;
		if (campus==Constants.CAMPUS_MIDDLE) campusChar="m";
		else if (campus==Constants.CAMPUS_UPPER) campusChar = "u";
		final String campusCharFinal = campusChar;
		String url = "http://www.burnsfamily.info/curriculum" + year + campusChar + ".hws";
		URLDownloader downloader = new URLDownloader(ctx, !isImportant);
		downloader.setOnCompleteListener(new URLDownloader.OnCompleteListener() {
			public void onDownloadComplete(String result) {
				SharedPreferences prefs = ctx.getSharedPreferences(year + campusCharFinal, Context.MODE_PRIVATE);
				prefs.edit().putString("curriculumJSON", result).commit();
				loadCurriculum(ctx, campus, year);
			}
		});
		if (isImportant) downloader.setOnErrorListener(new URLDownloader.OnErrorListener() {
			public void onDownloadError(Exception e) {
				Log.e("iHW", "Error downloading from URL: " + e.getClass() + " / " + e.getMessage());
				if (e instanceof java.io.FileNotFoundException) {
					new AlertDialog.Builder(ctx, R.style.PopupTheme).setMessage("Sorry, the school schedule for the campus and year you selected is not available.")
					.setPositiveButton("Back", new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int which) {
							Intent i = new Intent(ctx, LaunchActivity.class);
							ctx.startActivity(i);
						}
					}).show();
				}
			}
		});
		downloader.execute(url);
		return true;
	}
	
	public static int getCurrentYear(Context ctx) {
		SharedPreferences prefs = ctx.getSharedPreferences("iHW", Context.MODE_PRIVATE);
		return prefs.getInt("year", 0);
	}
	
	public static int getCurrentCampus(Context ctx) {
		SharedPreferences prefs = ctx.getSharedPreferences("iHW", Context.MODE_PRIVATE);
		return prefs.getInt("campus", 0);
	}
	
	public static void setCurrentYear(Context ctx, int year) {
		ctx.getSharedPreferences("iHW", Context.MODE_PRIVATE).edit().putInt("year", year).commit();
	}
	
	public static void setCurrentCampus(Context ctx, int campus) {
		ctx.getSharedPreferences("iHW", Context.MODE_PRIVATE).edit().putInt("campus", campus).commit();
	}
	
	public static void save(Context ctx) {
		String campusChar = null;
		int campus = getCurrentCampus(ctx);
		int year = getCurrentYear(ctx);
		if (campus==Constants.CAMPUS_MIDDLE) campusChar="m";
		else if (campus==Constants.CAMPUS_UPPER) campusChar = "u";
		SharedPreferences prefs = ctx.getSharedPreferences(year + campusChar, Context.MODE_PRIVATE);
		prefs.edit().putString("yearJSON", currentCurriculum.saveYear()).commit();
	}
	
	
	public static void deleteCurrentYear(Context ctx) {
		deleteYear(ctx, getCurrentCampus(ctx), getCurrentYear(ctx));
	}
	
	public static void deleteYear(Context ctx, int campus, int year) {
		String campusChar = null;
		if (campus==Constants.CAMPUS_MIDDLE) campusChar="m";
		else if (campus==Constants.CAMPUS_UPPER) campusChar = "u";
		SharedPreferences prefs = ctx.getSharedPreferences(year + campusChar, Context.MODE_PRIVATE);
		prefs.edit().remove("yearJSON").commit();
	}
	
	public static boolean isFirstRun(Context ctx) {
		if (getCurrentYear(ctx) == 0 || getCurrentCampus(ctx) == 0) return true;
		String campusChar = null;
		int campus = getCurrentCampus(ctx);
		int year = getCurrentYear(ctx);
		if (campus==Constants.CAMPUS_MIDDLE) campusChar="m";
		else if (campus==Constants.CAMPUS_UPPER) campusChar = "u";
		SharedPreferences prefs = ctx.getSharedPreferences(year + campusChar, Context.MODE_PRIVATE);
		if (!prefs.contains("yearJSON") || !prefs.contains("curriculumJSON")) return true;
		if (prefs.getString("yearJSON", "").equals(generateBlankYearJSON(campus, year))) return true;
		return false;
	}
	
	/**
	 * Generates a blank, new year JSON string with no courses or notes.
	 */
	public static String generateBlankYearJSON(int campus, int year) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("year", year);
			obj.put("campus", campus);
			obj.put("courses", new JSONArray());
			obj.put("notes", new JSONArray());
			return obj.toString(4);
		} catch (JSONException e) {return null;}
	}
	
	
	
	
	
	
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
		try {
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
			while(d.compareTo(semesterEndDates[2]) <= 0) {
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
			
			//rebuildSpecialDays();
			
			//initialize and store notes in map of maps
			JSONArray notesArr = yearObj.getJSONArray("notes");
			notes = new TreeMap<Date, TreeMap<Integer,List<Note>>>();
			for (int i=0; i<notesArr.length(); i++) {
				JSONObject obj = notesArr.getJSONObject(i);
				d = new Date(obj.getString("date"));
				int period = obj.getInt("period");
				String text = obj.getString("text");
				boolean isToDo = obj.getBoolean("isToDo");
				boolean checked = obj.getBoolean("isChecked");
				boolean isImportant = obj.getBoolean("isImportant");
				this.addNote(text, isToDo, checked, isImportant, d, period);
			}
		} catch (JSONException e) {}
	}
	
	/**
	 * When the user has changed his/her courses, the special days need to be reloaded. UNNECESSARY because
	 * the days are already built when they are displayed.
	 */
	/*private void rebuildSpecialDays() {
		for (Date d : specialDays.keySet()) {
			Day day = specialDays.get(d);
			if (day instanceof NormalDay) {
				((NormalDay)day).fillPeriods(this);
			}
		}
	}*/
	
	/**
	 * If day is special, return it from the list of special days.
	 * Otherwise generate the day and return it.
	 */
	public Day getDay(Date d) {
		try {
			if (specialDays.containsKey(d)) return specialDays.get(d);
			else if (d.compareTo(semesterEndDates[0]) < 0 ||
					d.compareTo(semesterEndDates[2]) > 0) return new Holiday(d, "Summer");
			else if (d.isWeekend()) return new Holiday(d, "");
			else if (d.isMonday()) {
				JSONArray namesArr = normalMondayTemplate.names();
				String[] names = new String[namesArr.length()];
				for (int i=0; i<names.length; i++) names[i] = (String)namesArr.get(i);
				JSONObject dayObj = new JSONObject(normalMondayTemplate, names);
				dayObj.put("date", d.toString());
				dayObj.put("dayNumber", dayNumbers.get(d));
				NormalDay ret = new NormalDay(dayObj);
				//ret.fillPeriods(this);
				return ret;
			} else {
				JSONArray namesArr = normalDayTemplate.names();
				String[] names = new String[namesArr.length()];
				for (int i=0; i<names.length; i++) names[i] = (String)namesArr.get(i);
				JSONObject dayObj = new JSONObject(normalDayTemplate, names);
				dayObj.put("date", d.toString());
				dayObj.put("dayNumber", dayNumbers.get(d));
				NormalDay ret = new NormalDay(dayObj);
				//ret.fillPeriods(this);
				return ret;
			}
		} catch (JSONException e) {return null;}
	}
	
	public List<String> getAllCourseNames() {
		List<String> list = new ArrayList<String>();
		for (Course c : courses) list.add(c.getName());
		return list;
	}
	
	public String saveYear() {
		try {
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
		} catch (JSONException e) {return null;}
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
						if (c.getMeetingOn(i) != Constants.MEETING_X_DAY &&
								check.getMeetingOn(i) != Constants.MEETING_X_DAY) return false;
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
						if (earlier.getMeetingOn(i) == Constants.MEETING_DOUBLE_AFTER &&
								later.getMeetingOn(i) != Constants.MEETING_X_DAY) return false;
						if (later.getMeetingOn(i) == Constants.MEETING_DOUBLE_BEFORE &&
								earlier.getMeetingOn(i) != Constants.MEETING_X_DAY) return false;
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
						if (earlier.getMeetingOn(i) == Constants.MEETING_DOUBLE_AFTER &&
								later.getMeetingOn(i) == Constants.MEETING_DOUBLE_BEFORE) return false;
					}
				}
			}
		}
		courses.add(c);
		//this.rebuildSpecialDays();
		return true;
	}
	
	public boolean replaceCourse(String oldName, Course c) {
		Course oldCourse = this.getCourse(oldName);
		this.removeCourse(oldCourse);
		if (this.addCourse(c)) {
			return true;
		} else {
			this.addCourse(oldCourse);
			return false;
		}
	}
	
	/**
	 * Returns true when two classes scheduled for terms a and b can coexist regardless
	 * of whether their periods conflict or not.
	 */
	private static boolean termsCompatible(int a, int b) {
		if (a==b) return false;
		if (a==Constants.TERM_FULL_YEAR || b==Constants.TERM_FULL_YEAR) return false;
		if (a==Constants.TERM_FIRST_SEMESTER) {
			if (b==Constants.TERM_FIRST_TRIMESTER || b==Constants.TERM_SECOND_TRIMESTER) return false;
		} else if (a==Constants.TERM_SECOND_SEMESTER) {
			if (b==Constants.TERM_SECOND_TRIMESTER || b==Constants.TERM_THIRD_TRIMESTER) return false;
		}
		if (b==Constants.TERM_FIRST_SEMESTER) {
			if (a==Constants.TERM_FIRST_TRIMESTER || a==Constants.TERM_SECOND_TRIMESTER) return false;
		} else if (b==Constants.TERM_SECOND_SEMESTER) {
			if (a==Constants.TERM_SECOND_TRIMESTER || a==Constants.TERM_THIRD_TRIMESTER) return false;
		}
		return true;
	}
	
	public List<Integer> termsFromDate(Date d) {
		List<Integer> list = new ArrayList<Integer>(3);
		if (d.compareTo(semesterEndDates[0]) >= 0) {
			if (d.compareTo(semesterEndDates[1]) <= 0) {
				list.add(Constants.TERM_FULL_YEAR);
				list.add(Constants.TERM_FIRST_SEMESTER);
			} else if (d.compareTo(semesterEndDates[2]) <= 0) {
				list.add(Constants.TERM_FULL_YEAR);
				list.add(Constants.TERM_SECOND_SEMESTER);
			}
		}
		if (d.compareTo(trimesterEndDates[0]) >= 0) {
			if (d.compareTo(trimesterEndDates[1]) <= 0) list.add(Constants.TERM_FIRST_TRIMESTER);
			else if (d.compareTo(trimesterEndDates[2]) <= 0) list.add(Constants.TERM_SECOND_TRIMESTER);
			else if (d.compareTo(trimesterEndDates[3]) <= 0) list.add(Constants.TERM_THIRD_TRIMESTER);
		}
		return list;
	}
	
	public Course getCourse(Date d, int period) {
		if (d.compareTo(semesterEndDates[0]) < 0 || d.compareTo(semesterEndDates[2]) > 0) return null;
		int dayNum = dayNumbers.get(d);
		//if (d.equals(new Date(5,28,2013))) System.out.println(dayNum);
		List<Integer> terms = termsFromDate(d);
		if (dayNum==0) {
			Course maxMeetings = null;
			int max = 1;
			for (Course c : courses) {
				boolean termFound = false;
				for (int term : terms) {
					if (term==c.getTerm()) {
						termFound = true;
						break;
					}
				}
				if (!termFound) continue;
				if (c.getPeriod() == period && c.getTotalMeetings() > max) {
					maxMeetings = c;
					max = c.getTotalMeetings();
				}
			}
			return maxMeetings;
		}
		for (Course c : courses) {
			boolean termFound = false;
			for (int term : terms) {
				if (term==c.getTerm()) {
					termFound = true;
					break;
				}
			}
			if (!termFound) continue;
			if (c.getPeriod()==period) {
				if (dayNum==0) return c;
				if (c.getMeetingOn(dayNum) != Constants.MEETING_X_DAY) return c; 
			} else if (period == c.getPeriod()-1) {
				if (c.getMeetingOn(dayNum) == Constants.MEETING_DOUBLE_BEFORE) return c;
			} else if (period == c.getPeriod()+1) {
				if (c.getMeetingOn(dayNum) == Constants.MEETING_DOUBLE_AFTER) return c;
			}
		}
		return null;
	}
	
	public Course getCourse(String name) {
		for (Course c : courses) if (c.getName().equals(name)) return c;
		return null;
	}
	
	public List<Note> getNotes(Date d, int period) {
		if (notes.get(d) != null) {
			Map<Integer, List<Note>> notesThisDay = notes.get(d);
			if (notesThisDay.containsKey(period)) {
				return notesThisDay.get(period);
			}
		}
		return new ArrayList<Note>(0);
	}
	
	public void addNote(String text, boolean isToDo, boolean checked, boolean isImportant, Date d, int period)
	{
		Note toAdd = new Note(text, isToDo, checked, isImportant);
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
	
	public Note removeNote(Date d, int period, String text) {
		if (notes.containsKey(d) && notes.get(d).containsKey(period)) {
			ListIterator<Note> iter = notes.get(d).get(period).listIterator();
			while (iter.hasNext()) {
				Note n = iter.next();
				if (n.getText().equals(text)) {
					iter.remove();
					return n;
				}
			}
		}
		return null;
	}
	
	public void setNotes(Date d, int period, List<Note> list) {
		if (notes.get(d) == null) { //if no notes this day
			TreeMap<Integer, List<Note>> inner = new TreeMap<Integer, List<Note>>();
			inner.put(period, list);
			notes.put(d, inner);
		} else {
			notes.get(d).put(period, list);
		}
	}
	
	public void removeCourse(Course c) {
		courses.remove(c);
		//rebuildSpecialDays();
	}
	
	public void removeAllCourses() {
		courses.clear();
		//rebuildSpecialDays();
	}

	public int getPassingPeriodLength() { return passingPeriodLength; }
	public int getCampus() { return campus; }
}
