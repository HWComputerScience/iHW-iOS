package com.ihwapp.android;

import com.ihwapp.android.model.Curriculum;
import com.ihwapp.android.model.Date;
import com.ihwapp.android.model.Day;
import com.ihwapp.android.model.NormalDay;
import com.ihwapp.android.model.Period;

import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

public class NotificationService extends IntentService implements Curriculum.ModelLoadingListener {
	private String title;
	private String text;
	private Date date;
	private int period;
	
	
	public NotificationService() {
		super("NotificationService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		Log.d("iHW", "Creating notification");
		title = intent.getStringExtra("notificationTitle");
		text = intent.getStringExtra("notificationText");
		date = new Date(intent.getStringExtra("date"));
		period = intent.getIntExtra("period", -1);
		if (date==null || period==-1) return;
		if (!Curriculum.getCurrentCurriculum().isLoaded()) {
			Curriculum.getCurrentCurriculum().addModelLoadingListener(this);
		} else {
			checkAndShowNotification();
		}
	}
	
	protected void checkAndShowNotification() {
		Day day = Curriculum.getCurrentCurriculum().getDay(date);
		if (day == null || !(day instanceof NormalDay)) return;
		if (day.getPeriods().size() < period+2) return;
		Period p = day.getPeriods().get(period);
		Period next = day.getPeriods().get(period+1);
		if (p != null && next != null && p.isFreePeriod() && !next.isFreePeriod()) {
			showNotification(title, text, text);
		}
	}
	
	protected void showNotification(String title, String text, String ticker) {
		Intent resultIntent = new Intent(this, LaunchActivity.class);
		PendingIntent pi = PendingIntent.getActivity(this, 0, resultIntent, 0);
		NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this)
			.setSmallIcon(R.drawable.notification_small)
			.setContentTitle(title)
			.setContentText(text)
			.setTicker(ticker)
			.setContentIntent(pi)
			.setAutoCancel(true)
			.setDefaults(Notification.DEFAULT_VIBRATE)
			.setOnlyAlertOnce(false);
		NotificationManager mNotificationManager =
			    (NotificationManager)this.getSystemService(Context.NOTIFICATION_SERVICE);
		mNotificationManager.notify(10, mBuilder.build());
	}

	public void onProgressUpdate(int progress) {}

	@Override
	public void onFinishedLoading(Curriculum c) {
		checkAndShowNotification();
	}
	
	public void onLoadFailed(Curriculum c) {}
}
