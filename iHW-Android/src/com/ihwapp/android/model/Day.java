package com.ihwapp.android.model;

import java.util.*;
import org.json.*;

public abstract class Day {
	protected Date date;
	protected List<Period> periods;
	
	public Day(Date d) {
		this.date = d;
	}
	
	public Day(JSONObject obj) {
		try {
			date = new Date(obj.getString("date"));
		} catch (JSONException e) {}
	}
	
	public com.ihwapp.android.model.Date getDate() { return date; }
	public List<Period> getPeriods() { return periods; }
	
	public JSONObject saveDay() {
		try {
			JSONObject toReturn = new JSONObject();
			toReturn.put("date", date);
			return toReturn;
		} catch (JSONException e) {return null;}
	}
}
