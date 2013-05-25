package model;

import java.util.*;
import org.json.*;

public abstract class Day {
	protected Date date;
	protected List<Period> periods;
	
	public Day(Date d) {
		this.date = d;
	}
	
	public Day(JSONObject obj) {
		date = new Date(obj.getString("date"));
	}
	
	public model.Date getDate() { return date; }
	
	public JSONObject saveDay() {
		JSONObject toReturn = new JSONObject();
		toReturn.put("date", date);
		return toReturn;
	}
}
