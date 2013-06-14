package com.ihwapp.android;

import android.os.Bundle;
import android.app.*;
import android.content.Intent;
import android.database.DataSetObserver;
import android.view.*;
import android.widget.*;

public class GuidedEditCoursesActivity extends ListActivity implements ListAdapter {
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_edit_courses);
		this.setTitle("Add Courses");
		this.setListAdapter(this);
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.guided_edit_courses, menu);
		return true;
	}
	
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.action_add) {
			Intent i = new Intent(this, AddCourseActivity.class);
			startActivity(i);
			return true;
		} else if (item.getItemId() == R.id.action_done) {
			Intent i = new Intent(this, ScheduleActivity.class);
			i.addFlags(
                    Intent.FLAG_ACTIVITY_CLEAR_TOP |
                    Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(i);
			this.finish();
			return true;
		}
		return false;
	}
	
	public void onListItemClick(ListView l, View v, int position, long id) {
		
	}

	
	
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public Object getItem(int position) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int position) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int getItemViewType(int position) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int getViewTypeCount() {
		return 1;
	}

	@Override
	public boolean hasStableIds() {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean isEmpty() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public void registerDataSetObserver(DataSetObserver observer) { }

	@Override
	public void unregisterDataSetObserver(DataSetObserver observer) { }

	@Override
	public boolean areAllItemsEnabled() {
		return true;
	}

	@Override
	public boolean isEnabled(int position) {
		return true;
	}
}

