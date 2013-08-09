package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;
import com.ihwapp.android.model.Date;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class LaunchActivity extends Activity {
	private boolean shouldFinish = false;
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Curriculum.ctx = this.getApplicationContext();
	}
	
	protected void onStart() {
		super.onStart();
		if (shouldFinish) {
			finish(); 
			return;
		}
		shouldFinish = true;
		Date d = new Date();
		d.add(Date.MONTH, -6);
		Curriculum.setCurrentYear(d.get(Date.YEAR));
		Intent i = null;
		if (Curriculum.isFirstRun()) {
			i = new Intent(this, FirstRunActivity.class);
		} else {
			i = new Intent(this, ScheduleActivity.class);
		}
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		this.startActivity(i);
	}
}
