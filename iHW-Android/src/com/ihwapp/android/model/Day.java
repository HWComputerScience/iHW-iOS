package com.ihwapp.android.model;

import java.util.*;
import org.json.*;

public abstract class Day {
	protected Date date;
	protected ArrayList<Period> periods;
	
	public Day(Date d) {
		this.date = d;
	}
	
	public Day(JSONObject obj) {
		try {
			date = new Date(obj.getString("date"));
		} catch (JSONException ignored) {}
	}
	
	public com.ihwapp.android.model.Date getDate() { return date; }
	public ArrayList<Period> getPeriods() { return periods; }
	
	public JSONObject saveDay() {
		try {
			JSONObject toReturn = new JSONObject();
			toReturn.put("date", date);
			return toReturn;
		} catch (JSONException e) {return null;}
	}
	
	public String getTitle() {
		return getDate().toString();
	}
}
