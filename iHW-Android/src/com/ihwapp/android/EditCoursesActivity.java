package com.ihwapp.android;

import android.os.Bundle;
import android.app.Activity;
import android.view.*;
import android.content.Intent;

public class EditCoursesActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_edit_courses);
		getActionBar().setDisplayHomeAsUpEnabled(true);
		this.setTitle("Edit Courses");
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.edit_courses, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId()==android.R.id.home) {
			Intent upIntent = new Intent(this, ScheduleActivity.class);
			upIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(upIntent);
			finish();
	        return true;
		}
		return false;
	}
}
