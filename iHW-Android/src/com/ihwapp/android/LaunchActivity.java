package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;

import android.app.Activity;
import android.content.Intent;

public class LaunchActivity extends Activity {
	private boolean shouldFinish = false;
	
	protected void onStart() {
		super.onStart();
		if (shouldFinish) {
			finish(); 
			return;
		}
		shouldFinish = true;
		Intent i = null;
		if (Curriculum.isFirstRun(this)) {
			i = new Intent(this, FirstRunActivity.class);
		} else {
			i = new Intent(this, ScheduleActivity.class);
		}
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		this.startActivity(i);
	}
}
