
package com.ihwapp.android.model;

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
		this.periods = new ArrayList<Period>(0);
		try {
			name = obj.getString("name");
		} catch (JSONException e) {}
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
		try {
			obj.put("name", name);
			obj.put("type", "holiday");
		} catch (JSONException e) {}
		return obj;
	}
	
	public String getName() { return name; }
}
