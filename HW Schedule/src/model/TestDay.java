package model;

import java.util.*;
import org.json.*;

public class TestDay extends Day {
	
	public TestDay(Date d, ArrayList<Period> tests) {
		super(d);
		this.periods = tests;
	}
	
	public TestDay(JSONObject obj) {
		super(obj);
		JSONArray tests = obj.getJSONArray("tests");
		this.periods = new ArrayList<Period>(tests.length());
		for (int i=0; i<tests.length(); i++) {
			periods.add(new Period(tests.getJSONObject(i)));
		}
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
		obj.put("type", "test");
		JSONArray tests = new JSONArray();
		for (Period p : periods) {
			tests.put(p.savePeriod());
		}
		obj.put("tests", tests);
		return obj;
	}
}
