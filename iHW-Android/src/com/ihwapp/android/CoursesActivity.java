package com.ihwapp.android;

import java.util.Arrays;

import com.ihwapp.android.model.Curriculum;

import android.os.Bundle;
import android.app.*;
import android.content.Intent;
import android.database.DataSetObserver;
import android.graphics.Color;
import android.view.*;
import android.widget.*;

public abstract class CoursesActivity extends ListActivity implements ListAdapter {
	private String[] courseNames;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_courses);
	}
	
	protected void onStart() {
		super.onStart();
		//TODO if (!Curriculum.loadCurrentCurriculum(this)) finish();
		reloadData();
		this.getListView().setDivider(this.getResources().getDrawable(android.R.drawable.divider_horizontal_bright));
		this.getListView().setMultiChoiceModeListener(new ListSelectionListener());
		this.getListView().setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);
	}
	
	private void reloadData() {
		Object[] courseObjs = Curriculum.getCurrentCurriculum().getAllCourseNames().toArray();
		courseNames = Arrays.copyOf(courseObjs, courseObjs.length, String[].class);
		this.setListAdapter(this);
	}
	
	@Override
	public abstract boolean onCreateOptionsMenu(Menu menu);
	
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.action_add) {
			Intent i = new Intent(this, EditCourseActivity.class);
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
		} else if (item.getItemId() == android.R.id.home) {
			this.finish();
			return true;
		}
		return false;
	}
	
	public void onListItemClick(ListView l, View v, int position, long id) {
		Intent i = new Intent(this, EditCourseActivity.class);
		i.putExtra("courseName", courseNames[position]);
		startActivity(i);
	}

	@Override
	public int getCount() {
		return courseNames.length;
	}

	@Override
	public Object getItem(int position) {
		return courseNames[position];
	}

	@Override
	public long getItemId(int position) {
		//return courseNames[position].hashCode();
		return position;
	}

	@Override
	public int getItemViewType(int position) {
		return 0;
	}

	@Override
	public View getView(final int position, View convertView, ViewGroup parent) {
		if (convertView == null) {
			convertView = this.getLayoutInflater().inflate(R.layout.list_item_course, null);
		}
		((TextView)convertView.findViewById(R.id.text_course_name)).setText(courseNames[position]);
		convertView.setBackgroundResource(R.drawable.list_item_selector);
		return convertView;
	}

	@Override
	public int getViewTypeCount() {
		return 1;
	}

	@Override
	public boolean hasStableIds() {
		return true;
	}

	@Override
	public boolean isEmpty() {
		return getCount() == 0;
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
	
	private class ListSelectionListener implements AbsListView.MultiChoiceModeListener {
		
		@Override
		public boolean onPrepareActionMode(ActionMode mode, Menu menu) {
			return true;
		}
		
		@Override
		public void onDestroyActionMode(ActionMode mode) {
			int i=0;
			View child = getListView().getChildAt(i);
			while (child != null) {
				child.setBackgroundColor(Color.TRANSPARENT);
				i++;
				child = getListView().getChildAt(i);
			}
		}
		
		@Override
		public boolean onCreateActionMode(ActionMode mode, Menu menu) {
			getMenuInflater().inflate(R.menu.cab_courses, menu);
			return true;
		}
		
		@Override
		public boolean onActionItemClicked(ActionMode mode, MenuItem item) {
			if (item.getItemId() == R.id.action_edit) {
				Intent i = new Intent(CoursesActivity.this, EditCourseActivity.class);
				i.putExtra("courseName", courseNames[(int)getListView().getCheckedItemIds()[0]]);
				startActivity(i);
			} else if (item.getItemId() == R.id.action_delete) {
				Curriculum c = Curriculum.getCurrentCurriculum();
				long[] checked = getListView().getCheckedItemIds();
				for (int i=0; i<checked.length; i++) {
					c.removeCourse(c.getCourse(courseNames[(int)checked[i]]));
				}
				Curriculum.save();
				reloadData();
				mode.finish();
				return true;
			}
			return false;
		}
		
		@Override
		public void onItemCheckedStateChanged(ActionMode mode, int position,
				long id, boolean checked) {
			//View item = getListView().getChildAt(position-getListView().getFirstVisiblePosition());
			//if (checked) item.setBackgroundColor(Color.argb(127, 180, 225, 255));
			//else item.setBackgroundColor(Color.TRANSPARENT);
			if (getListView().getCheckedItemCount() == 1) mode.getMenu().findItem(R.id.action_edit).setVisible(true);
			else mode.getMenu().findItem(R.id.action_edit).setVisible(false);
		}
	}
}

