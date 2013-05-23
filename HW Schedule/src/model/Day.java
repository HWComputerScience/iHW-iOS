package model;

import java.util.*;
import org.json.*;

public abstract class Day {
	protected Date date;
	protected Time startTime;
	protected Time endTime;
	protected List<Period> periods;
	
	public model.Date getDate() { return date; }
	public Time getStartTime() { return startTime; }
	public Time getEndTime() { return endTime; }
	
	public JSONObject saveDay() {
		JSONObject toReturn = new JSONObject();
		toReturn.put("date", date);
		toReturn.put("startTime", startTime);
		toReturn.put("endTime", endTime);
		return null;
	}
}
