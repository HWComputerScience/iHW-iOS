package model;

import java.util.*;
import org.json.*;

public abstract class Day {
	protected Date date;
	protected Time startTime;
	protected Time endTime;
	protected List<Period> periods;
	
	public Date getDate() { return date; }
	public Time getStartTime() { return startTime; }
	public Time getEndTime() { return endTime; }
	
	public JSONObject saveDay() {
		//TODO: Save stuff common with all days
		return null;
	}
}
