package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;

import android.app.IntentService;
import android.content.Intent;

public class UpdateService extends IntentService {
	public UpdateService() {
		super("UpdateService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		Curriculum.reloadCurrentCurriculum();
	}

}
