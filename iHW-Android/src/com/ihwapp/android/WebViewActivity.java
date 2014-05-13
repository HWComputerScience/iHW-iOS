package com.ihwapp.android;

import android.os.Bundle;
import android.webkit.WebView;

public class WebViewActivity extends IHWActivity {
	private String title;
	private String url;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_web_view);
		this.title = getIntent().getStringExtra("title");
		this.url = getIntent().getStringExtra("urlstr");
	}
	
	@Override
	protected void onStart() {
		super.onStart();
		setTitle(this.title);
		((WebView)this.findViewById(R.id.web_view)).loadUrl(this.url);
	}
}
