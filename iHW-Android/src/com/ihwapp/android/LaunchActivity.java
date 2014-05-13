package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;

import android.content.Intent;
import android.os.Bundle;

public class LaunchActivity extends IHWActivity {
	private boolean shouldFinish = false;
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}
	
	protected void onStart() {
		super.onStart();
		if (shouldFinish) {
			finish(); 
			return;
		}
		shouldFinish = true;
		Intent i;
		if (Curriculum.isFirstRun()) {
			i = new Intent(this, FirstRunActivity.class);
			i.putExtra("skipToCourses", false);
		} else if (Curriculum.shouldPromptForCourses()) {
			i = new Intent(this, FirstRunActivity.class);
			i.putExtra("skipToCourses", true);
		} else {
			Curriculum.reloadCurrentCurriculum();
			i = new Intent(this, ScheduleActivity.class);
		}
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		this.startActivity(i);
	}
}
