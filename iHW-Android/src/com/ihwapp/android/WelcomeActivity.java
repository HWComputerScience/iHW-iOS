package com.ihwapp.android;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;

public class WelcomeActivity extends Activity {
	private boolean shouldFinish = false;
	
	protected void onStart() {
		super.onStart();
		if (shouldFinish) {
			finish(); 
			return;
		}
		shouldFinish = true;
		SharedPreferences settings = getPreferences(MODE_PRIVATE);
		Intent i = null;
		if (settings.getBoolean("firstRun", true)) {
			//settings.edit().putBoolean("firstRun", false).apply();
			i = new Intent(this, FirstRunActivity.class);
		} else {
			i = new Intent(this, ScheduleActivity.class);
		}
		i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		this.startActivity(i);
	}
}
