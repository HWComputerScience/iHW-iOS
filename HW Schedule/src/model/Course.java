package model;

import org.json.*;

public class Course {
	public static final int MEETING_X_DAY = 0;
	public static final int MEETING_SINGLE_PERIOD = 1;
	public static final int MEETING_DOUBLE_BEFORE = 2;
	public static final int MEETING_DOUBLE_AFTER = 3;
	
	private String name;
	private int period;
	private int term;
	private int[] meetings;
	
	public Course(String name, int period, int term, int[] meetings) {
		this.setName(name);
		this.setPeriod(period);
		this.setMeetings(meetings);
		this.setTerm(term);
	}
	
	public Course(JSONObject obj) {
		name=obj.getString("name");
		period=obj.getInt("period");
		term=obj.getInt("term");
		JSONArray meetingsArr = obj.getJSONArray("meetings");
		meetings = new int[meetingsArr.length()];
		for (int i=0; i<meetingsArr.length(); i++) {
			meetings[i]=meetingsArr.getInt(i);
		}
	}
	
	public JSONObject saveCourse() {
		JSONObject obj = new JSONObject();
		obj.put("name", name);
		obj.put("period", period);
		obj.put("term", term);
		obj.put("meetings", meetings);
		return obj;
	}

	public String getName() { return name; }
	public void setName(String name) { this.name = name; }
	public int getPeriod() { return period; }
	public void setPeriod(int period) { this.period = period; }
	public int getTerm() { return term; }
	public void setTerm(int term) { this.term = term; }

	public int getMeetingOn(int dayNum) {
		return meetings[dayNum-1];
	}

	public void setMeetings(int[] meetings) { this.meetings = meetings; }
}
