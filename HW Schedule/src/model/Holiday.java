package model;

import org.json.*;

public class Holiday extends Day {
	private String name;
	
	public Holiday(String name) {
		this.name = name;
		this.periods = new Period[0];
		this.startTime = new Time(8,0);
		this.startTime = new Time(8,0);
	}
	
	public Holiday(JSONObject obj) {
		//load from JSON object
	}
	
	public String getName() { return name; }
}
