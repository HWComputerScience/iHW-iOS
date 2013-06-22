package com.ihwapp.android;

import com.ihwapp.android.model.*;

import android.os.Bundle;
import android.content.Intent;
import android.support.v4.app.*;
import android.support.v4.view.ViewPager;
import android.view.*;

public class ScheduleActivity extends FragmentActivity {
	private ViewPager pager;
	private DayPagerAdapter adapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_schedule);
		this.setTitle("View Schedule!");
		if (savedInstanceState == null) Curriculum.reloadCurrentCurriculum(this);
		else Curriculum.loadCurrentCurriculum(this);
	}
	
	protected void onStart() {
		super.onStart();
		adapter = new DayPagerAdapter(this.getSupportFragmentManager());
		int item = Math.min(new Date(7,1,Curriculum.getCurrentYear(this)).getDaysUntil(new Date()), adapter.getCount()-1);
		if (pager != null) item = pager.getCurrentItem();
		pager = ((ViewPager)this.findViewById(R.id.scheduleViewPager));
		pager.setAdapter(adapter);
		pager.setOffscreenPageLimit(3);
		pager.setCurrentItem(item);
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
		}
		return false;
	}
	
	private class DayPagerAdapter extends FragmentStatePagerAdapter {
		public DayPagerAdapter(FragmentManager fm) {
			super(fm);
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
