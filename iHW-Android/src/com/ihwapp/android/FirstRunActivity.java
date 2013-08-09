package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;

import android.app.*;
import android.content.Intent;
import android.os.Bundle;
import android.view.*;
import android.widget.*;

public class FirstRunActivity extends Activity {
	private LinearLayout campusLayout;
	private LinearLayout coursesLayout;
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setContentView(R.layout.activity_firstrun);
		campusLayout = (LinearLayout)this.findViewById(R.id.layout_choose_campus);
		coursesLayout = (LinearLayout)this.findViewById(R.id.layout_get_courses);
		
		Button msCampus = (Button)this.findViewById(R.id.button_campus_ms);
		msCampus.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Curriculum.setCurrentCampus(Constants.CAMPUS_MIDDLE);
				Curriculum.getCurrentCurriculum();
				//Log.d("iHW", "Loading curriculum: " + Curriculum.loadCurrentCurriculum(FirstRunActivity.this));
				campusLayout.setVisibility(View.GONE);
				coursesLayout.setVisibility(View.VISIBLE);
			}
		});
		
		Button usCampus = (Button)this.findViewById(R.id.button_campus_us);
		usCampus.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Curriculum.setCurrentCampus(Constants.CAMPUS_UPPER);
				Curriculum.getCurrentCurriculum();
				//Log.d("iHW", "Loading curriculum: " + Curriculum.loadCurrentCurriculum(FirstRunActivity.this));
				campusLayout.setVisibility(View.GONE);
				coursesLayout.setVisibility(View.VISIBLE);
			}
		});
		
		Button downloadButton = (Button)this.findViewById(R.id.button_download);
		downloadButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent(FirstRunActivity.this, DownloadScheduleActivity.class);
				i.putExtra("firstRun", true);
				startActivity(i);
			}
		});
		
		Button editCoursesButton = (Button)this.findViewById(R.id.button_add_manually);
		editCoursesButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent(FirstRunActivity.this, GuidedCoursesActivity.class);
				i.putExtra("firstRun", true);
				startActivity(i);
			}
		});
	}
	
	public void onBackPressed() {
		if (campusLayout.getVisibility() == View.VISIBLE) {
			super.onBackPressed();
		} else {
			campusLayout.setVisibility(View.VISIBLE);
			coursesLayout.setVisibility(View.GONE);
		}
	}
}
