package com.ihwapp.android.model;

import java.util.*;
import org.json.*;

public abstract class Day {
	protected Date date;
	protected ArrayList<Period> periods;
	protected String caption;
	protected String captionLink;
	
	public Day(Date d) {
		this.date = d;
	}
	
	public Day(JSONObject obj) {
		try {
			date = new Date(obj.getString("date"));
			caption = obj.getString("caption");
			captionLink = obj.getString("captionLink");
		} catch (JSONException ignored) {}
	}
	
	public com.ihwapp.android.model.Date getDate() { return date; }
	public ArrayList<Period> getPeriods() { return periods; }
	
	public JSONObject saveDay() {
		try {
			JSONObject toReturn = new JSONObject();
			toReturn.put("date", date);
			toReturn.put("caption", caption);
			toReturn.put("captionLink", captionLink);
			return toReturn;
		} catch (JSONException e) {return null;}
	}
	
	public String getTitle() {
		return getDate().toString();
	}
	
	public String getCaption() { return caption; }
	public String getCaptionLink() { return captionLink; }
	
	public void setCaption(String c) { caption = c; }
	public void setCaptionLink(String l) { captionLink = l; }
}
