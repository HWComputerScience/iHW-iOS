package com.ihwapp.android;

import android.app.IntentService;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

public class NotificationService extends IntentService {
	public NotificationService() {
		super("NotificationService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this)
			.setSmallIcon(R.drawable.ic_action_go_to_today)
			.setContentTitle(intent.getStringExtra("notificationTitle"))
			.setContentText(intent.getStringExtra("notificationText"));
		Intent resultIntent = new Intent(this, LaunchActivity.class);
		PendingIntent pi = PendingIntent.getActivity(this, 0, resultIntent, 0);
		NotificationManager mNotificationManager =
			    (NotificationManager)this.getSystemService(Context.NOTIFICATION_SERVICE);
		mNotificationManager.notify(10, mBuilder.build());
	}

}
