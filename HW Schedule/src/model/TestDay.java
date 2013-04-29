package model;

public class TestDay extends Day {
	
	public TestDay(Period[] tests) {
		this.periods = tests;
		this.startTime = periods[0].getStartTime();
		this.endTime = periods[periods.length-1].getEndTime();
	}
}
