package com.ihwapp.android;

import java.util.*;

import org.json.*;

import com.ihwapp.android.model.*;
import com.ihwapp.android.model.Date;

import android.support.v4.app.Fragment;
import android.text.InputType;
import android.util.Log;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.*;
import android.view.inputmethod.EditorInfo;
import android.widget.*;

public class DayFragment extends Fragment {
	private Day day;
	private int initScrollPos;
	private ArrayList<OnFragmentVisibilityChangedListener> ofvcls;
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		initScrollPos = 0;
		ofvcls = new ArrayList<OnFragmentVisibilityChangedListener>();
		if (savedInstanceState != null) {
			setArguments(savedInstanceState);
			initScrollPos = savedInstanceState.getInt("scrollPos");
		}
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
		//Typeface georgiaBold = Typeface.createFromAsset(getActivity().getAssets(), "fonts/Georgia Bold.ttf");
		/*Date d = day.getDate();
		String weekdayName = d.getDisplayName(GregorianCalendar.DAY_OF_WEEK, GregorianCalendar.SHORT, Locale.getDefault());
		String title = weekdayName + ", " + d.toString();
		if (day instanceof NormalDay && ((NormalDay)day).getDayNumber() > 0) title += " (Day " + ((NormalDay)day).getDayNumber() + ")";
		((TextView)v.findViewById(R.id.date_view)).setText(title);*/
		TextView titleText = ((TextView)v.findViewById(R.id.date_view));
		titleText.setText(day.getTitle());
		titleText.setTypeface(Typeface.SERIF, Typeface.BOLD);
		if (day instanceof NormalDay) ((NormalDay)day).fillPeriods(Curriculum.getCurrentCurriculum(getActivity()));
		String dayName = "";
		if (day instanceof Holiday) {
			dayName = ((Holiday)day).getName();
		}
		TextView dayNameText = ((TextView)v.findViewById(R.id.text_day_title));
		dayNameText.setTypeface(Typeface.SERIF, Typeface.BOLD);
		if (dayName.equals("")) dayNameText.setVisibility(View.GONE);
		else dayNameText.setText(dayName);
		ArrayList<Period> pds = day.getPeriods();
		LinearLayout pdsLayout = ((LinearLayout)v.findViewById(R.id.layout_periods));
		for (int i=0; i<pds.size(); i++) {
			Period p = pds.get(i);
			View periodView = inflater.inflate(R.layout.view_period, null);
			if (p.getNum() > 0) {
				((TextView)periodView.findViewById(R.id.text_periodnum)).setText(getOrdinal(p.getNum()));
			}
			((TextView)periodView.findViewById(R.id.text_title)).setText(p.getName());
			((TextView)periodView.findViewById(R.id.text_starttime)).setText(p.getStartTime().toString12());
			((TextView)periodView.findViewById(R.id.text_endtime)).setText(p.getEndTime().toString12());
			FrameLayout fl = new FrameLayout(getActivity());
			int id=day.getDate().getDay()*100+i;
			fl.setId(id);
			//Log.d("iHW", "adding placeholder " + day.getDate().toString() + ":" + i);
			((LinearLayout)periodView.findViewById(R.id.layout_right)).addView(fl);
			pdsLayout.addView(periodView);
			pdsLayout.addView(new Separator(getActivity()));
		}
		TextView moreNotesLabel = new TextView(getActivity());
		if (pds.size() > 0) moreNotesLabel.setText("Additional Notes");
		else moreNotesLabel.setText("Notes");
		pdsLayout.addView(moreNotesLabel);
		PeriodNotesFragment f = PeriodNotesFragment.newInstance(day.getDate(), -1);
		this.addOnFragmentVisibilityChangedListener(f);
		this.getChildFragmentManager().beginTransaction().replace(R.id.layout_periods, f, day.getDate().toString() + ":-1").commit();
		return v;
	}
	
	public void onStart() {
		super.onStart();
		List<Period> pds = day.getPeriods();
		for (int i=0; i<pds.size(); i++) {
			int id=day.getDate().getDay()*100+i;
			//Log.d("iHW", "adding fragment " + day.getDate().toString() + ":" + i);
			if (getView().findViewById(id) != null) {
				PeriodNotesFragment f = PeriodNotesFragment.newInstance(day.getDate(), i);
				this.getChildFragmentManager().beginTransaction().add(id, f, day.getDate().toString() + ":" + i).commit();
			}
		}
		
		final ScrollView sv = (ScrollView)getView().findViewById(R.id.scroll_periods);
		sv.post(new Runnable() { 
			public void run() { 
				sv.scrollTo(0, initScrollPos);
			} 
		});
		
	}
	
	public void setUserVisibleHint(boolean isVisibleToUser) {
		if (this.getUserVisibleHint() != isVisibleToUser && (this.isVisible() || isVisibleToUser) && ofvcls != null) {
			for (OnFragmentVisibilityChangedListener l : ofvcls) {
				l.onFragmentVisibilityChanged(this, isVisibleToUser);
			}
		}
		super.setUserVisibleHint(isVisibleToUser);
	}
	
	public void addOnFragmentVisibilityChangedListener(OnFragmentVisibilityChangedListener l) { ofvcls.add(l); }
	public void removeOnFragmentVisibilityChangedListener(OnFragmentVisibilityChangedListener l) { ofvcls.remove(l); }
	
	public void onPause() {
		super.onPause();
		initScrollPos = ((ScrollView)getView().findViewById(R.id.scroll_periods)).getScrollY();
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
	
	public interface OnFragmentVisibilityChangedListener {
		public void onFragmentVisibilityChanged(Fragment f, boolean isVisible);
	}
}
