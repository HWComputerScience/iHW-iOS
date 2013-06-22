package com.ihwapp.android;

import java.util.GregorianCalendar;
import java.util.List;
import java.util.Locale;

import org.json.*;

import com.ihwapp.android.model.*;

import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.*;
import android.widget.*;

public class DayFragment extends Fragment {
	private Day day;
	private int initScrollPos;
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		initScrollPos = 0;
		if (savedInstanceState != null) {
			setArguments(savedInstanceState);
			initScrollPos = savedInstanceState.getInt("scrollPos");
		}
	}
	
	public void onStart() {
		super.onStart();
		final ScrollView sv = (ScrollView)getView().findViewById(R.id.scroll_periods);
		sv.post(new Runnable() { 
			public void run() { 
				sv.scrollTo(0, initScrollPos);
			} 
		});
	}
	
	public void onPause() {
		super.onPause();
		initScrollPos = ((ScrollView)getView().findViewById(R.id.scroll_periods)).getScrollY();
	}
	
	public void setArguments(Bundle b) {
		try {
			JSONObject dayJSON = new JSONObject((String)b.get("dayJSON"));
			String type = dayJSON.getString("type");
			if (type.equals("normal")) {
				day = new NormalDay(dayJSON);
			}
			else if (type.equals("test")) day = new TestDay(dayJSON);
			else if (type.equals("holiday")) day = new Holiday(dayJSON);
		} catch (JSONException e) { }
	}

	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View v = inflater.inflate(R.layout.fragment_day, null);
		Date d = day.getDate();
		String weekdayName = d.getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.SHORT, Locale.getDefault());
		String title = weekdayName + ", " + d.toString();
		if (day instanceof NormalDay && ((NormalDay)day).getDayNumber() > 0) title += " (Day " + ((NormalDay)day).getDayNumber() + ")";
		((TextView)v.findViewById(R.id.date_view)).setText(title);
		if (day instanceof NormalDay) ((NormalDay)day).fillPeriods(Curriculum.getCurrentCurriculum(getActivity()));
		
		String dayName = "";
		if (day instanceof Holiday) {
			dayName = ((Holiday)day).getName();
		}
		TextView tv = ((TextView)v.findViewById(R.id.text_day_title));
		if (dayName.equals("")) tv.setVisibility(View.GONE);
		else tv.setText(dayName);
		List<Period> pds = day.getPeriods();
		LinearLayout pdsLayout = ((LinearLayout)v.findViewById(R.id.layout_periods));
		for (Period p : pds) {
			View periodView = inflater.inflate(R.layout.view_period, null);
			if (p.getNum() > 0) {
				((TextView)periodView.findViewById(R.id.text_periodnum)).setText(getOrdinal(p.getNum()));
			}
			((TextView)periodView.findViewById(R.id.text_title)).setText(p.getName());
			((TextView)periodView.findViewById(R.id.text_starttime)).setText(p.getStartTime().toString12());
			((TextView)periodView.findViewById(R.id.text_endtime)).setText(p.getEndTime().toString12());
			pdsLayout.addView(periodView);
			pdsLayout.addView(new Separator(getActivity()));
		}
		return v;
	}
	
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putString("dayJSON", day.saveDay().toString());
		outState.putInt("scrollPos", ((ScrollView)getView().findViewById(R.id.scroll_periods)).getScrollY());
	}
	
	private static String getOrdinal(int num) {
		String suffix = "";
		if (num%10==1) suffix="st";
		else if (num%10==2) suffix="nd";
		else if (num%10==3) suffix="rd";
		else suffix = "th";
		return num+suffix;
	}
}
