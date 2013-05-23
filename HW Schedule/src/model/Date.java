package model;

public class Date implements org.json.JSONString {
	private int day;
	private int month;
	private int year;
	
	public Date(int day, int month, int year) {
		this.day=day;
		this.month=month;
		this.year=year;
	}
	
	public int getDay() {
		return day;
	}
	public void setDay(int day) {
		if (day>31 || day<1) throw new IllegalArgumentException();
		this.day = day;
	}
	public int getMonth() {
		return month;
	}
	public void setMonth(int month) {
		if (month<1 || month>12) throw new IllegalArgumentException();
		this.month = month;
	}
	public int getYear() {
		return year;
	}
	public void setYear(int year) {
		this.year = year;
	}
	
	public boolean equals(Object obj) {
		if (!(obj instanceof Date)) return false;
		Date other = (Date)obj;
		return (this.day==other.day && this.month==other.month && this.year==other.year);
	}

	@Override
	public String toJSONString() {
		return "\"" + day + "/" + month + "/" + year + "\"";
	}
}
