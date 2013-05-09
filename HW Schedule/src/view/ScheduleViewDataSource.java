package view;

import java.util.Date;
import model.Course;
import model.Day;

public interface ScheduleViewDataSource {
	Day getDay(Date d);
	Course getCourse(String name);
}
