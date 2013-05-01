package model;

import java.util.*;

public class Period {
	private String name;
	private Time startTime;
	private Time endTime;
	private List<Note> notes;
	
	public Period(String name, Time start, Time end) {
		this.name = name;
		this.startTime = start;
		this.endTime = end;
		notes = new LinkedList<Note>();
	}
	
	public String getName() { return name; }
	public Time getStartTime() { return startTime; }
	public Time getEndTime() { return endTime; }
	public List<Note> getNotes() { return new ArrayList<Note>(notes); }
	
	public void addNote(Note note) {
		notes.add(note);
	}
	
	public void removeNote(Note note) {
		notes.remove(note);
	}
	
	public static Period newFreePeriod(Time start, Time end) {
		return new Period("Free", start, end);
	}
}
