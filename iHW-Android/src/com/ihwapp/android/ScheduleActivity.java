package com.ihwapp.android;

import java.util.Locale;

import com.ihwapp.android.model.*;

import android.graphics.*;
import android.os.Bundle;
import android.app.DatePickerDialog;
import android.content.*;
import android.support.v4.app.*;
import android.support.v4.view.*;
import android.view.*;
import android.view.ViewGroup.LayoutParams;
import android.widget.*;

public class ScheduleActivity extends FragmentActivity {
	private ViewPager pager;
	private CustomFontPagerTitleStrip pts;
	private DayPagerAdapter adapter;
	private Date currentDate;
	private int[] newDate;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_schedule);
		this.setTitle("View Schedule!");
		//this.getActionBar().setBackgroundDrawable(new ColorDrawable(Color.parseColor("#990000")));
		if (savedInstanceState == null) Curriculum.reloadCurrentCurriculum(this);
		else Curriculum.loadCurrentCurriculum(this);
	}
	
	@SuppressWarnings("deprecation")
	protected void onStart() {
		super.onStart();
		//Typeface georgia = Typeface.createFromAsset(getAssets(), "fonts/Georgia.ttf");
		adapter = new DayPagerAdapter(this.getSupportFragmentManager());
		int item = -1;
		//item = Math.min(new Date(7,1,Curriculum.getCurrentYear(this)).getDaysUntil(new Date()), adapter.getCount()-1);
		if (pager != null) item = pager.getCurrentItem();
		pager = ((ViewPager)this.findViewById(R.id.scheduleViewPager));
		pager.setSaveEnabled(false);
		if (pager.findViewById("pager_title_strip".hashCode()) == null) {
			pts = new CustomFontPagerTitleStrip(this);
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
				currentDate = new Date(7,1,Curriculum.getCurrentYear(ScheduleActivity.this)).dateByAdding(position);
			}
			
			public void onPageScrolled(int arg0, float arg1, int arg2) { }
			public void onPageScrollStateChanged(int arg0) { }
		});
		pager.setAdapter(adapter);
		pager.setOffscreenPageLimit(1);
		if (item>=0) pager.setCurrentItem(item, false);
		else gotoDate(new Date());
	}
	
	public void gotoDate(Date d) {
		int position = new Date(7,1,Curriculum.getCurrentYear(ScheduleActivity.this)).getDaysUntil(d);
		if (position < 0) Toast.makeText(ScheduleActivity.this, "Please select a previous year (if available) from the \"choose years\" menu item to view that date.", Toast.LENGTH_LONG).show();
		else if (position > adapter.getCount()) Toast.makeText(ScheduleActivity.this, "Please select a future year (if available) from the \"choose years\" menu item to view that date.", Toast.LENGTH_LONG).show();
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
		}
		return false;
	}
	
	public void onBackPressed() {
		super.onBackPressed();
		/*InputMethodManager ims = ((InputMethodManager)this.getSystemService(INPUT_METHOD_SERVICE));
		Log.d("iHW", ims.isAcceptingText() + " " + ims.isActive());*/
	}
	
	private class DayPagerAdapter extends FragmentStatePagerAdapter {
		public DayPagerAdapter(FragmentManager fm) {
			super(fm);
		}
		
		public String getPageTitle(int position) {
			Date date = new Date(7,1,Curriculum.getCurrentYear(ScheduleActivity.this)).dateByAdding(position);
			//Day d = Curriculum.getCurrentCurriculum(ScheduleActivity.this).getDay(date);
			return date.getDayOfWeek(false).toUpperCase(Locale.getDefault());
		}

		@Override
		public Fragment getItem(int position) {
			Date date = new Date(7,1,Curriculum.getCurrentYear(ScheduleActivity.this)).dateByAdding(position);
			Day d = Curriculum.getCurrentCurriculum(ScheduleActivity.this).getDay(date);
			Fragment f = new DayFragment();
			Bundle b = new Bundle();
			b.putString("dayJSON", d.saveDay().toString());
			f.setArguments(b);
			return f;
		}

		@Override
		public int getCount() {
			return new Date(7,1,Curriculum.getCurrentYear(ScheduleActivity.this))
					.getDaysUntil(new Date(7,1,Curriculum.getCurrentYear(ScheduleActivity.this)+1));
		}
	}
}
