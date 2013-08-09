package com.ihwapp.android.model;

import org.json.*;

public class Period {
	private String name;
	private Time startTime;
	private Time endTime;
	//private List<Note> notes;
	private Date d;
	private int periodNum;
	
	public Period(String name, Date d, Time start, Time end, int periodNum) {
		this.name = name;
		this.startTime = start;
		this.endTime = end;
		this.d=d;
		this.periodNum=periodNum;
		//notes = new LinkedList<Note>();
	}
	
	public Period(JSONObject obj) {
		try {
			this.name = obj.getString("name");
			this.startTime = new Time(obj.getString("startTime"));
			this.endTime = new Time(obj.getString("endTime"));
			this.d = new Date(obj.getString("date"));
			this.periodNum = obj.getInt("periodNum");
		} catch (JSONException e) {}
	}
	
	public String getName() { return name; }
	public Time getStartTime() { return startTime; }
	public Time getEndTime() { return endTime; }
	//public List<Note> getNotes() { return new ArrayList<Note>(notes); }
	//public void setNotes(List<Note> notes) { this.notes = notes; }
	public Date getDate() { return d; }
	public void setDate(Date d) { this.d = d; }
	public int getNum() { return periodNum; }
	public void setNum(int periodNum) { this.periodNum = periodNum; }
	
	public JSONObject savePeriod() {
		JSONObject obj = new JSONObject();
		try {
			obj.put("name", name);
			obj.put("startTime", startTime);
			obj.put("endTime", endTime);
			obj.put("date", d);
			obj.put("periodNum", periodNum);
		} catch (JSONException e) {}
		return obj;
	}
}
