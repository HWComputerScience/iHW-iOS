package model;

import java.util.*;
import org.json.*;

public class Holiday extends Day {
	private String name;
	
	public Holiday(String name) {
		this.name = name;
		this.periods = new ArrayList<Period>(0);
		this.startTime = new Time(8,0);
		this.startTime = new Time(8,0);
	}
	
	public Holiday(JSONObject obj) {
		//TODO: load from JSON object
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
		obj.put("name", name);
		obj.put("type", "holiday");
		return obj;
	}
	
	public String getName() { return name; }
}
