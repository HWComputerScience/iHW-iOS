package view;

import java.util.List;

import model.Date;
import model.Course;
import model.Day;
import model.Note;

public interface ScheduleViewDataSource {
	Day getDay(Date d);
	Course getCourse(String name);
	List<Note> getNotes(Date d, int period);
}
