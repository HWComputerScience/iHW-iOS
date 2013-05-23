package view;

import model.Date;
import model.Course;
import model.Day;

public interface ScheduleViewDataSource {
	Day getDay(Date d);
	Course getCourse(String name);
}
