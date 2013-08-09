package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.Menu;

public class GuidedCoursesActivity extends CoursesActivity {
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setTitle("Add Your Courses");
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.guided_courses, menu);
		return true;
	}
	
	public void onBackPressed() {
		if (getCount() > 0) {
			new AlertDialog.Builder(this).setMessage("Are you sure you want to go back? You will lose the courses you have added.")
			.setNegativeButton("Go Back", new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					Curriculum.getCurrentCurriculum().removeAllCourses();
					Curriculum.save();
					GuidedCoursesActivity.this.finish();
				}
			}).setPositiveButton("Keep Editing", null).show();
		} else {
			super.onBackPressed();
		}
	}
}
