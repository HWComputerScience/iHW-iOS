package com.ihwapp.android.model;

import java.util.*;

import org.json.*;

import android.os.Parcel;
import android.os.Parcelable;

public class Period implements Parcelable {
	private String name;
	private Time startTime;
	private Time endTime;
	private ArrayList<Note> notes;
	private Date d;
	private int periodNum;
	private int periodIndex;
	
	public Period(String name, Date d, Time start, Time end, int periodNum, int periodIndex) {
		this.name = name;
		this.startTime = start;
		this.endTime = end;
		this.d = d;
		this.periodNum = periodNum;
		this.periodIndex = periodIndex;
		loadNotesFromCurriculum();
	}
	
	public Period(JSONObject obj, int periodIndex) {
		try {
			this.name = obj.getString("name");
			this.startTime = new Time(obj.getString("startTime"));
			this.endTime = new Time(obj.getString("endTime"));
			this.d = new Date(obj.getString("date"));
			this.periodNum = obj.getInt("periodNum");
			this.periodIndex = periodIndex;
			loadNotesFromCurriculum();
		} catch (JSONException ignored) {}
	}
	
	public String getName() { return name; }
	public Time getStartTime() { return startTime; }
	public Time getEndTime() { return endTime; }
	public List<Note> getNotes() { return notes; }
	public void setNotes(ArrayList<Note> notes) { this.notes = notes; }
	public Date getDate() { return d; }
	//public void setDate(Date d) { this.d = d; }
	public int getNum() { return periodNum; }
	//public void setNum(int periodNum) { this.periodNum = periodNum; }
	public int getIndex() { return periodIndex; }
	public void setIndex(int index) { this.periodIndex = index; }
	
	public void loadNotesFromCurriculum() {
		this.notes = Curriculum.getCurrentCurriculum().getNotes(d, periodIndex);
		if (this.notes == null) this.notes = new ArrayList<Note>();
	}
	
	public void saveNotes() {
		Curriculum.getCurrentCurriculum().setNotes(d, periodIndex, notes);
		Curriculum.getCurrentCurriculum().saveWeek(d);
	}
	
	public JSONObject savePeriod() {
		JSONObject obj = new JSONObject();
		try {
			obj.put("name", name);
			obj.put("startTime", startTime);
			obj.put("endTime", endTime);
			obj.put("date", d);
			obj.put("periodNum", periodNum);
		} catch (JSONException ignored) {}
		return obj;
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(name);
		dest.writeParcelable(startTime, flags);
		dest.writeParcelable(endTime, flags);
		dest.writeTypedList(notes);
		dest.writeSerializable(d);
		dest.writeInt(periodNum);
		dest.writeInt(periodIndex);
	}
	
	public static final Parcelable.Creator<Period> CREATOR = new Parcelable.Creator<Period>() {
		public Period createFromParcel(Parcel in) {
		    return new Period(in);
		}
		
		public Period[] newArray(int size) {
		    return new Period[size];
		}
	};
	
	public Period(Parcel in) {
		this.name = in.readString();
		this.startTime = Time.CREATOR.createFromParcel(in);
		this.endTime = Time.CREATOR.createFromParcel(in);
		ArrayList<Note> notesToSet = new ArrayList<Note>();
		in.readTypedList(notesToSet, Note.CREATOR);
		this.notes = notesToSet;
		this.d = (Date)in.readSerializable();
		this.periodNum = in.readInt();
		this.periodIndex = in.readInt();
	}
}
