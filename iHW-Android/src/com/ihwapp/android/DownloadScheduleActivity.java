package com.ihwapp.android;

import org.jsoup.Jsoup;
import org.jsoup.nodes.*;
import org.jsoup.select.Elements;

import android.os.*;
import android.annotation.*;
import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.view.*;
import android.widget.*;
import android.webkit.*;

public class DownloadScheduleActivity extends Activity {
	public static final String TAG = "webkit-test";
	private boolean alreadyLoaded = false;
	private WebView webview;
	private final Activity thisActivity = this;

	@SuppressLint("SetJavaScriptEnabled")
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_download);
		webview = (WebView)this.findViewById(R.id.webView_download);
		webview.getSettings().setJavaScriptEnabled(true);
		webview.getSettings().setSupportZoom(true);
		webview.getSettings().setBuiltInZoomControls(true);
		webview.setWebViewClient(new WebViewClient() {
			public boolean shouldOverrideUrlLoading(WebView view, String url)
			{
				if (url.equals("http://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx") ||
						url.equals("https://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx") ||
						url.equals("https://www.hw.com/students/Login/tabid/2279/Default.aspx?returnurl=%2fstudents%2fSchoolResources%2fMyScheduleEvents.aspx")) {
					//Log.d(TAG, "Loading URL: " + url);
					return false;
				}
				//Log.d(TAG, "Preventing you from loading URL: " + url);
				return true;
			}

			public void onPageFinished (WebView view, String url) {
				//Log.d(TAG, "Loading page finished.");
				if (url.equals("http://www.hw.com/students/SchoolResources/MyScheduleEvents.aspx")) {
					//Log.d(TAG, "Loaded My Schedule and Events");
					if (!alreadyLoaded) {
						((LinearLayout)findViewById(R.id.LinearLayout1)).setGravity(Gravity.CENTER);
						changeInfoText("Please wait, finding schedule...");
						view.setVisibility(View.INVISIBLE);
						view.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0));
						alreadyLoaded = true;
						view.loadUrl("javascript:__doPostBack(\"dnn$ctr8420$InteractiveSchedule$lnkStudentScheduleHTML\", \"\");");
					} else {						
						view.loadUrl("javascript:console.log(\"SCHEDULE_URL=\"+document.getElementById(\"dnn_ctr8420_InteractiveSchedule_txtWindowPopupUrl\").value)");
					}
				}
			}
		});
		webview.setWebChromeClient(new WebChromeClient() {
			public boolean onConsoleMessage (ConsoleMessage consoleMessage) {
				if (consoleMessage.message().startsWith("SCHEDULE_URL=")) {
					new DownloadParseScheduleTask().execute(consoleMessage.message().substring(13));
				}
				return false;
			}
		});
		android.webkit.CookieManager.getInstance().removeAllCookie();
		webview.loadUrl("https://www.hw.com/students/Login/tabid/2279/Default.aspx?returnurl=%2fstudents%2fSchoolResources%2fMyScheduleEvents.aspx");
	}
	
	/**
	 * Set up the {@link android.app.ActionBar}, if the API is available.
	 */
	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	private void setupActionBar() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB && !this.getIntent().getBooleanExtra("firstRun", false)) {
			getActionBar().setDisplayHomeAsUpEnabled(true);
		}
	}

	private void changeInfoText(String s) {
		TextView tv = (TextView)findViewById(R.id.empty);
		tv.setText(s);
	}

	private class DownloadParseScheduleTask extends AsyncTask<String, Void, Document> {
		protected void onPreExecute() {
			changeInfoText("Schedule found. Downloading...");
		}
		protected Document doInBackground(String...url) {
			Log.d(TAG, "Downloading/parsing HTML");
			Document doc = null;
			try {
				doc = Jsoup.connect(url[0]).get();
			} catch (Exception e) {
				Log.e(TAG, e.getClass().getName() + " Downloading/parsing HTML");
				e.printStackTrace();
			}
			return doc;
		}

		protected void onPostExecute(Document result) {
			Elements divs = result.getElementsByTag("div");
			for (Element div : divs) {
				if (div.attr("id").equals("nameStudentName1-0")) {
					Log.d(TAG, "Name: " + div.getElementsByTag("span").first().text());
				} else if (div.attr("id").equals("sectCode1")) {
					Log.d(TAG, "Course code: " + div.getElementsByTag("span").first().text());
				} else if (div.attr("id").equals("sectTitle1")) {
					Log.d(TAG, "Course name: " + div.getElementsByTag("span").first().text());
				} else if (div.attr("id").equals("sectPeriodList1")) {
					Log.d(TAG, "Course meets: " + div.getElementsByTag("span").first().text());
				} else if (div.attr("id").equals("Subreport8")) {
					break;
				}
			}
			/*changeInfoText("Schedule downloaded.");
			ProgressBar pb = ((ProgressBar)findViewById(R.id.progressBar1));
			pb.setVisibility(View.INVISIBLE);*/
			Intent i = new Intent(thisActivity, NormalCoursesActivity.class);
			startActivity(i);
		}
	}

}
