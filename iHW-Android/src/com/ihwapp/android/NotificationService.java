package com.ihwapp.android;

import android.app.IntentService;
import android.app.Notification;
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
		Log.d("iHW", "Creating notification");
		Intent resultIntent = new Intent(this, LaunchActivity.class);
		PendingIntent pi = PendingIntent.getActivity(this, 0, resultIntent, 0);
		NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this)
			.setSmallIcon(R.drawable.notification_small)
			.setContentTitle(intent.getStringExtra("notificationTitle"))
			.setContentText(intent.getStringExtra("notificationText"))
			.setTicker(intent.getStringExtra("notificationText"))
			.setContentIntent(pi)
			.setAutoCancel(true)
			.setDefaults(Notification.DEFAULT_VIBRATE)
			.setOnlyAlertOnce(false);
		NotificationManager mNotificationManager =
			    (NotificationManager)this.getSystemService(Context.NOTIFICATION_SERVICE);
		mNotificationManager.notify(10, mBuilder.build());
	}

}
