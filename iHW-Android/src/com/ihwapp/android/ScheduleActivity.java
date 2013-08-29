package com.ihwapp.android;

import java.util.Locale;

import com.ihwapp.android.model.*;

import android.graphics.*;
import android.os.Bundle;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.*;
import android.support.v4.app.*;
import android.support.v4.view.*;
import android.util.Log;
import android.view.*;
import android.view.ViewGroup.LayoutParams;
import android.widget.*;

public class ScheduleActivity extends FragmentActivity implements Curriculum.ModelLoadingListener{
	private ViewPager pager;
    private DayPagerAdapter adapter;
	private Date currentDate;
	private int[] newDate;
	private int lastIndex;
	private ProgressDialog progressDialog;

	@SuppressWarnings("deprecation")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d("iHW-lc", "ScheduleActivity onCreate");
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_schedule);
		this.setTitle("View Schedule");
		if (savedInstanceState != null) lastIndex = savedInstanceState.getInt("lastIndex");
		else lastIndex = -1;
		
		if (pager == null) pager = ((ViewPager)this.findViewById(R.id.scheduleViewPager));
		if (adapter == null) adapter = new DayPagerAdapter(this.getSupportFragmentManager());
		if (pager.findViewById("pager_title_strip".hashCode()) == null) {
            CustomFontPagerTitleStrip pts = new CustomFontPagerTitleStrip(this);
			pts.setId("pager_title_strip".hashCode());
			pts.setTypeface(Typeface.SERIF);
			pts.setBackgroundDrawable(getResources().getDrawable(R.drawable.dark_tan));
			pts.setTextColor(Color.BLACK);
			ViewPager.LayoutParams params = new ViewPager.LayoutParams();
			params.height = LayoutParams.WRAP_CONTENT;
			params.gravity = Gravity.TOP;
			pts.setPadding(0, 4, 0, 4);
			pager.addView(pts, 0, params);
		}
		pager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
			public void onPageSelected(int position) {
				currentDate = new Date(7,1,Curriculum.getCurrentYear()).dateByAdding(position);
				lastIndex = position;
				Curriculum.getCurrentCurriculum().clearUnnededItems(currentDate);
			}
			
			public void onPageScrolled(int arg0, float arg1, int arg2) { }
			public void onPageScrollStateChanged(int arg0) { }
		});
		pager.setOffscreenPageLimit(2);
	}
	
	protected void onStart() {
		super.onStart();
		Log.d("iHW-lc", "ScheduleActivity onStart: first loaded date " + Curriculum.getCurrentCurriculum().getFirstLoadedDate());
		//Typeface georgia = Typeface.createFromAsset(getAssets(), "fonts/Georgia.ttf");
		if (Curriculum.getCurrentCurriculum().isLoaded()) {
			Log.d("iHW", "Setting adapter");
			pager.setAdapter(adapter);
			adapter.enabled = true;
			if (lastIndex >= 0) pager.setCurrentItem(lastIndex, false);
			else gotoDate(new Date());
		} else {
			Curriculum.getCurrentCurriculum().addModelLoadingListener(this);
		}
	}
	
	@Override
	public void onProgressUpdate(int progress) {
		if (progress < 4 && progressDialog == null) {
			progressDialog = new ProgressDialog(this, R.style.PopupTheme);
			progressDialog.setCancelable(false);
			progressDialog.setMessage("Loading...");
			progressDialog.show();
		}
	}

	@Override
	public void onFinishedLoading(Curriculum c) {
		Log.d("iHW", "## onFinishedLoading");
		Log.d("iHW-lc", "ScheduleActivity onFinishedLoading");
		pager.setAdapter(adapter);
		adapter.enabled = true;
		if (lastIndex >= 0) pager.setCurrentItem(lastIndex, false);
		else gotoDate(new Date());
		if (progressDialog != null) progressDialog.dismiss();
		progressDialog = null;
	}
	
	public void onLoadFailed(Curriculum c) {
		if (progressDialog != null) progressDialog.dismiss();
		progressDialog = null;
		new AlertDialog.Builder(this, R.style.PopupTheme).setMessage("iHW requires internet access when running for the first time. Please try again later when you are connected to a Wi-Fi or cellular network.")
		.setPositiveButton("Cancel", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				Intent i = new Intent(ScheduleActivity.this, LaunchActivity.class);
				startActivity(i);
			}
		})
		.setNegativeButton("Retry", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int which) {
				Curriculum.reloadCurrentCurriculum().addModelLoadingListener(ScheduleActivity.this);
			}
		}).show();
	}
	
	public void gotoDate(Date d) {
		int position = new Date(7,1,Curriculum.getCurrentYear()).getDaysUntil(d);
		if (position < 0) Toast.makeText(ScheduleActivity.this, "Please select a previous year (if available) from the \"Options\" menu item to view that date.", Toast.LENGTH_LONG).show();
		else if (position > adapter.getCount()) Toast.makeText(ScheduleActivity.this, "Please select a future year (if available) from the \"Options\" menu item to view that date.", Toast.LENGTH_LONG).show();
		position = Math.max(0, Math.min(adapter.getCount()-1, position));
		if (currentDate==null) pager.setCurrentItem(position, false);
		else pager.setCurrentItem(position, true);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.schedule, menu);
		return true;
	}
	
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.action_edit_courses) {
			Intent i = new Intent(this, NormalCoursesActivity.class);
			startActivity(i);
			return true;
		} else if (item.getItemId() == R.id.action_goto_today) {
			//int pos = Math.min(new Date(7,1,Curriculum.getCurrentYear(this)).getDaysUntil(new Date()), adapter.getCount()-1);
			//pager.setCurrentItem(pos);
			gotoDate(new Date());
		} else if (item.getItemId() == R.id.action_goto_date) {
			DatePickerDialog dpd = new DatePickerDialog(this, R.style.PopupTheme, null, currentDate.getYear(), currentDate.getMonth()-1, currentDate.getDay());
			dpd.getDatePicker().init(currentDate.getYear(), currentDate.getMonth()-1, currentDate.getDay(), new DatePicker.OnDateChangedListener() {
				public void onDateChanged(DatePicker view, int year, int monthOfYear,
						int dayOfMonth) {
					newDate = new int[] {year, monthOfYear, dayOfMonth};
				}
			});
			dpd.setButton(DatePickerDialog.BUTTON_POSITIVE, "Go", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					if (newDate==null) return;
					Date d = new Date(newDate[1]+1, newDate[2], newDate[0]);
					gotoDate(d);
				}
			});
			dpd.show();
		} else if (item.getItemId() == R.id.action_refresh) {
			Curriculum.reloadCurrentCurriculum().addModelLoadingListener(this);
		} else if (item.getItemId() == R.id.action_options) {
			Intent i = new Intent(this, PreferencesActivity.class);
			startActivity(i);
			return true;
		}
		return false;
	}
	
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		Log.d("iHW-lc", "ScheduleActivity onSaveInstanceState");
		outState.putInt("lastIndex", pager.getCurrentItem());
	}
	
	public void onPause() {
		super.onPause();
		Log.d("iHW-lc", "ScheduleActivity onPause");
	}
	
	public void onStop() {
		Log.d("iHW-lc", "ScheduleActivity onStop");
		super.onStop();
	}
	
	public void onDestroy() {
		Log.d("iHW-lc", "ScheduleActivity onDestroy");
		super.onDestroy();
	}
	
	/*public void onBackPressed() {
		super.onBackPressed();
		/*InputMethodManager ims = ((InputMethodManager)this.getSystemService(INPUT_METHOD_SERVICE));
		Log.d("iHW", ims.isAcceptingText() + " " + ims.isActive());
	}*/
	
	private class DayPagerAdapter extends FragmentStatePagerAdapter {
		public boolean enabled = false;
		private final int count = new Date(7,1,Curriculum.getCurrentYear())
		.getDaysUntil(new Date(7,1,Curriculum.getCurrentYear()+1));
		
		public DayPagerAdapter(FragmentManager fm) {
			super(fm);
		}
		
		public String getPageTitle(int position) {
			if (!enabled) return "";
			Date date = new Date(7,1,Curriculum.getCurrentYear()).dateByAdding(position);
			//Day d = Curriculum.getCurrentCurriculum(ScheduleActivity.this).getDay(date);
			return date.getDayOfWeek(false).toUpperCase(Locale.getDefault());
		}

		@Override
		public Fragment getItem(int position) {
			if (!enabled) return new Fragment();
			Date date = new Date(7,1,Curriculum.getCurrentYear()).dateByAdding(position);
			DayFragment f = new DayFragment();
			Bundle b = new Bundle();
			Log.d("iHW", "pager: " + pager + " asked for " + date.toString());
			b.putString("date", date.toString());
			f.setArguments(b);
			return f;
		}

		@Override
		public int getCount() {
			return count;
		}
	}
}
