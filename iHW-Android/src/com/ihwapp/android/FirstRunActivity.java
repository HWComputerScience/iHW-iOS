package com.ihwapp.android;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.*;
import android.widget.*;

public class FirstRunActivity extends Activity {
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setContentView(R.layout.activity_firstrun);
		final Activity thisActivity = this;
		
		Button downloadButton = (Button)this.findViewById(R.id.button_download);
		downloadButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent(thisActivity, DownloadScheduleActivity.class);
				i.putExtra("firstRun", true);
				startActivity(i);
			}
		});
		
		Button editCoursesButton = (Button)this.findViewById(R.id.button_add_manually);
		editCoursesButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent(thisActivity, GuidedEditCoursesActivity.class);
				i.putExtra("firstRun", true);
				startActivity(i);
			}
		});
	}
}
