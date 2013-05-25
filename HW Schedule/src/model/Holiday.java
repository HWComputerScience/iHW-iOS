package model;

import java.util.*;
import org.json.*;

public class Holiday extends Day {
	private String name;
	
	public Holiday(Date d, String name) {
		super(d);
		this.name = name;
		this.periods = new ArrayList<Period>(0);
	}
	
	public Holiday(JSONObject obj) {
		super(obj);
		name = obj.getString("name");
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
		obj.put("name", name);
		obj.put("type", "holiday");
		return obj;
	}
	
	public String getName() { return name; }
}
