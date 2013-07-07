package com.ihwapp.android;

import android.content.Context;
import android.graphics.Typeface;
import android.support.v4.view.PagerTitleStrip;
import android.util.AttributeSet;

public class CustomFontPagerTitleStrip extends PagerTitleStrip {
	Typeface typeface;
	
	public CustomFontPagerTitleStrip(Context context) {
		super(context);
	}
	public CustomFontPagerTitleStrip(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	
	public Typeface getTypeface() {
		return typeface;
	}
	public void setTypeface(Typeface typeface) {
		this.typeface = typeface;
	}
	
	protected void onLayout(boolean changed, int l, int t, int r, int b) {
		super.onLayout(changed, l, t, r, b);
		if (typeface==null) return;
		for (int i=0; i<this.getChildCount(); i++) {
			if (this.getChildAt(i) instanceof android.widget.TextView) {
				((android.widget.TextView)this.getChildAt(i)).setTypeface(typeface);
			}
		}
	}
}