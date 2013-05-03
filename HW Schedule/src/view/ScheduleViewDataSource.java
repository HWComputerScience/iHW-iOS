package view;

import java.util.Date;

import model.Day;

public interface ScheduleViewDataSource {
	Day getDay(Date d);
}
