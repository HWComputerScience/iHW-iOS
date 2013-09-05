package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;

import android.app.Activity;
import android.os.Bundle;

public class IHWActivity extends Activity {
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Curriculum.ctx = this.getApplicationContext();
	}
}
