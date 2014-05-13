package com.ihwapp.android;

import java.util.*;

import com.ihwapp.android.model.*;
import com.ihwapp.android.model.Date;

import android.support.v4.app.Fragment;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Bundle;
import android.view.*;
import android.view.View.OnClickListener;
import android.widget.*;

public class DayFragment extends Fragment {
	private Date date;
	private Day day;
	private int initScrollPos;
	private ArrayList<OnFragmentVisibilityChangedListener> ofvcls;
	private Timer countdownTimer;
	//private View countdownView;
	private ArrayList<PeriodView> periodViews;
	
	/*****LIFECYCLE -- BEGINNINGS*****/
	
	public void setArguments(Bundle b) {
		date = new Date(b.getString("date"));
	}
	
	public void onAttach(Activity activity) {
		super.onAttach(activity);
		//Log.d("iHW-lc", "DayFragment onAttach");
	}
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (!Curriculum.getCurrentCurriculum().isLoaded()) return;
		initScrollPos = 0;
		ofvcls = new ArrayList<OnFragmentVisibilityChangedListener>();
		if (savedInstanceState != null && savedInstanceState.containsKey("date")) {
			date = new Date(savedInstanceState.getString("date"));
			initScrollPos = savedInstanceState.getInt("scrollPos");
		}
		day = Curriculum.getCurrentCurriculum().getDay(date);
		//Log.d("iHW-lc", "DayFragment onCreate: " + date);
	}

	public View onCreateView(final LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		//Log.d("iHW-lc", "DayFragment onCreateView: " + date);
		final View v = inflater.inflate(R.layout.fragment_day, null);
		if (!Curriculum.getCurrentCurriculum().isLoaded()) return v;
        assert v != null;
        TextView titleText = ((TextView)v.findViewById(R.id.date_view));
		//Log.d("iHW", "Day: " + day);
		titleText.setText(day.getTitle());
		titleText.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
		
		ArrayList<Period> pds = day.getPeriods();
		
		LinearLayout pdsLayout = ((LinearLayout)v.findViewById(R.id.layout_periods));
		periodViews = new ArrayList<PeriodView>(pds.size());

        for (final Period p : pds) {
            final PeriodView periodView = new PeriodView(getActivity());
            DayFragment.this.addOnFragmentVisibilityChangedListener(periodView);
            periodView.setPeriod(p);
            periodViews.add(periodView);

            pdsLayout.addView(periodView);
            pdsLayout.addView(new Separator(getActivity()));
        }
				
		PeriodView moreNotesView = new PeriodView(getActivity());
		DayFragment.this.addOnFragmentVisibilityChangedListener(moreNotesView);
		String moreNotesTitle;
		if (pds.size() > 0) moreNotesTitle = "Additional Notes";
		else moreNotesTitle = "Notes";
		moreNotesView.setPeriod(new Period(moreNotesTitle, date, new Time(0,0), new Time(0,0), 0, -1));
		pdsLayout.addView(moreNotesView);
		
		String dayName = "";
		if (day instanceof Holiday) {
			dayName = ((Holiday)day).getName();
		}
		TextView dayNameText = ((TextView)v.findViewById(R.id.text_day_title));
		dayNameText.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
		if (dayName.equals("")) dayNameText.setVisibility(View.GONE);
		else dayNameText.setText(dayName);
		
		TextView dayCaptionText = ((TextView)v.findViewById(R.id.text_day_caption));
		if (day.getCaption() != null && day.getCaption() != "") {
			dayCaptionText.setText(day.getCaption());
			if (day.getCaptionLink() != null && day.getCaptionLink() != "") {
				v.findViewById(R.id.layout_caption).setOnClickListener(new OnClickListener() {
					public void onClick(View v) {
						Intent i = new Intent(Intent.ACTION_VIEW);
						i.setData(Uri.parse(day.getCaptionLink()));
						startActivity(i);
					}
				});
			} else {
				v.findViewById(R.id.image_caption_link).setVisibility(View.GONE);
			}
		} else {
			v.findViewById(R.id.layout_caption).setVisibility(View.GONE);
		}
		
		return v;
	}
	
	public Date getDate() { return date; }
	
	public void onStart() {
		super.onStart();
		//Log.d("iHW-lc", "DayFragment onStart: " + date);
	}
	
	public void onResume() {
		super.onResume();
		//Log.d("iHW-lc", "DayFragment onResume: " + date);
		final ScrollView sv = (ScrollView)getView().findViewById(R.id.scroll_periods);
		sv.setFocusableInTouchMode(true);
		sv.post(new Runnable() { 
			public void run() { 
				sv.scrollTo(0, initScrollPos);
			} 
		});
		countdownTimer = new Timer();
		countdownTimer.schedule(new TimerTask() {
			public void run() {
				if (getActivity() == null) return;
				getActivity().runOnUiThread(new Runnable() {
					public void run() {
						if (periodViews == null) return;
						for (PeriodView pv : periodViews) {
							pv.addCountdownTimerIfNeeded();
						}
					}
				});
			}
		}, 0, 60000);
	}
	
	/*****LIFECYCLE -- ENDINGS*****/
	
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		//Log.d("iHW-lc", "DayFragment onSaveInstanceState: " + date);
		//outState.putString("dayJSON", day.saveDay().toString());
		outState.putString("date", date.toString());
		outState.putInt("scrollPos", getView().findViewById(R.id.scroll_periods).getScrollY());
	}
	
	public void onPause() {
		super.onPause();
		//Log.d("iHW-lc", "DayFragment (" + this + ") onPause: " + date);
		initScrollPos = getView().findViewById(R.id.scroll_periods).getScrollY();
		countdownTimer.cancel();
		countdownTimer = null;
	}
	
	public void onStop() {
		super.onStop();
		//Log.d("iHW-lc", "DayFragment onStop: " + date);
		//if (countdownTimer != null) countdownTimer.cancel();
		//if (countdownView != null) countdownView.setVisibility(View.GONE);
		if (this.getUserVisibleHint() && ofvcls != null) {
			for (OnFragmentVisibilityChangedListener l : ofvcls) {
				l.onFragmentVisibilityChanged(this, false);
			}
		}
	}
	
	public void onDestroyView() {
		//Log.d("iHW-lc", "DayFragment onDestroyView: " + date);
		super.onDestroyView();
		periodViews.clear();
		periodViews = null;
		//countdownTimer = null;
		//countdownView = null;
		((ViewGroup)this.getView()).removeAllViews();
	}
	
	public void onDestroy() {
		//Log.d("iHW-lc", "DayFragment onDestroy: " + date);
		super.onDestroy();
	}
	
	public void onDetach() {
		//Log.d("iHW-lc", "DayFragment " + this + " onDetach from " + this.getActivity() + ": " + date);
		super.onDetach();
		if (date==null) return;
		this.ofvcls.clear();
		this.ofvcls = null;
		day = null;
		date = null;
	}
	
	/*****OTHER METHODS*****/
	
	/*public void resetCountdownTimer() {
		countdownTimer.cancel();
		countdownTimer = null;
		countdownView.setVisibility(View.GONE);
		countdownView = null;
		ArrayList<Period> pds = day.getPeriods();
		for (int i=0; i<pds.size(); i++) {
			Period p = pds.get(i);
			int minsUntil = new Time().minutesUntil(p.getStartTime());
			// fix criteria for timer being shown:
			if (day.getDate().equals(new Date()) && minsUntil < p.getStartTime().minutesUntil(p.getEndTime()) && minsUntil > 0) {
				this.addCountdownTimerToPeriod(p, periodViews.get(i));
			}
		}
	}
	
	public void addCountdownTimerToPeriod(final Period p, final View periodView) {
		//Log.d("iHW", i + " " + new Time() + ", " + p.getStartTime());
		if (countdownView != null) countdownView.setVisibility(View.GONE);
		countdownView = periodView.findViewById(R.id.text_countdown);
		countdownView.setVisibility(View.VISIBLE);
		if (countdownTimer != null) countdownTimer.cancel();
		countdownTimer = new Timer();
		countdownTimer.scheduleAtFixedRate(new TimerTask() {
			public void run() {
				getActivity().runOnUiThread(new Runnable() {
					public void run() {
						int minsUntil = new Time().minutesUntil(p.getStartTime());
						int secsUntil = new Time().secondsUntil(p.getStartTime()) % 60;
						if (secsUntil != 0) minsUntil++;
						if (minsUntil <= 0 && secsUntil <= 0) {
							periodView.findViewById(R.id.text_countdown).setVisibility(View.GONE);
							resetCountdownTimer();
							return;
						}
						String secs = "" + secsUntil;
						if (secsUntil < 10) secs = "0" + secs;
						((TextView)periodView.findViewById(R.id.text_countdown)).setText("Starts in " + minsUntil + ":" + secs);
					}
				});
			}
		}, 0, 1000);
	}*/
	
	public void setUserVisibleHint(boolean isVisibleToUser) {
		//Log.d("iHW-lc", "DayFragment setUserVisibleHint: " + isVisibleToUser + "(" + date + ")");
		if (this.getUserVisibleHint() != isVisibleToUser && (this.isVisible() || isVisibleToUser) && ofvcls != null) {
			for (OnFragmentVisibilityChangedListener l : ofvcls) {
				l.onFragmentVisibilityChanged(this, isVisibleToUser);
			}
		}
		super.setUserVisibleHint(isVisibleToUser);
	}
	
	public void addOnFragmentVisibilityChangedListener(OnFragmentVisibilityChangedListener l) { ofvcls.add(l); }
	//public void removeOnFragmentVisibilityChangedListener(OnFragmentVisibilityChangedListener l) { ofvcls.remove(l); }
	
	public interface OnFragmentVisibilityChangedListener {
		public void onFragmentVisibilityChanged(Fragment f, boolean isVisible);
	}
}
