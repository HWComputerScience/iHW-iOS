package com.ihwapp.android;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;

public class Separator extends View {

	public Separator(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		LayoutParams params = new ViewGroup.LayoutParams(LayoutParams.MATCH_PARENT, 1);
		this.setLayoutParams(params);
		this.setBackgroundColor(Color.GRAY);
	}
	
	public Separator(Context context, AttributeSet attrs) {
		super(context, attrs);
		LayoutParams params = new ViewGroup.LayoutParams(LayoutParams.MATCH_PARENT, 1);
		this.setLayoutParams(params);
		this.setBackgroundColor(Color.GRAY);
	}
	
	public Separator(Context c) {
		super(c);
		LayoutParams params = new ViewGroup.LayoutParams(LayoutParams.MATCH_PARENT, 1);
		this.setLayoutParams(params);
		this.setBackgroundColor(Color.GRAY);
	}
	
}