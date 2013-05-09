package model;

import java.util.*;
import org.json.*;

public class TestDay extends Day {
	
	public TestDay(ArrayList<Period> tests) {
		this.periods = tests;
		this.startTime = periods.get(0).getStartTime();
		this.endTime = periods.get(periods.size()-1).getEndTime();
	}
	
	public TestDay(JSONObject obj) {
		//TODO: Load from JSON object
	}
	
	public JSONObject saveDay() {
		JSONObject obj = super.saveDay();
		//TODO: add test-day-specific stuff to json object (including "type"="test")
		return obj;
	}
}
