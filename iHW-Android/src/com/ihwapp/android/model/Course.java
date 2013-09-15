package com.ihwapp.android.model;

import org.json.*;

public class Course {
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
		try {
			name=obj.getString("name");
			period=obj.getInt("period");
			term=obj.getInt("term");
			JSONArray meetingsArr = obj.getJSONArray("meetings");
			meetings = new int[meetingsArr.length()];
			for (int i=0; i<meetingsArr.length(); i++) {
				meetings[i]=meetingsArr.getInt(i);
			}
		} catch (JSONException ignored) {}
	}
	
	public JSONObject saveCourse() {
		try {
			JSONObject obj = new JSONObject();
			obj.put("name", name);
			obj.put("period", period);
			obj.put("term", term);
			JSONArray meetingsArr = new JSONArray();
			for (int meeting : meetings) {
				meetingsArr.put(meeting);
			}
			obj.put("meetings", meetingsArr);
			return obj;
		} catch (JSONException e) {return null;}
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
	
	public int getTotalMeetings() {
		int sum = 0;
		for (int meeting : meetings) {
			if (meeting>0) sum++;
			if (meeting>1) sum++;
		}
		return sum;
	}

	public void setMeetings(int[] meetings) { this.meetings = meetings; }
}
