package com.ihwapp.android;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.text.*;
import android.util.AttributeSet;
import android.view.*;
import android.widget.*;

public class AddCourseActivity extends Activity {
	//private ActionMode cab;
	private int numPeriods = 8;
	private int numDays = 5;
	private EditText nameBox;
	private EditText periodBox;
	private Spinner termBox;
	private TableLayout meetingsLayout;
	private CheckBox[][] checkboxes;
	private TextView[] periodHeaders;
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setContentView(R.layout.activity_add_course);
		this.setTitle("Add a Course");
		
		nameBox = (EditText)this.findViewById(R.id.courseNameBox);
		periodBox = (EditText)this.findViewById(R.id.coursePeriodBox);
		termBox = (Spinner)this.findViewById(R.id.courseTermBox);
		
		meetingsLayout = (TableLayout)this.findViewById(R.id.courseMeetingsLayout);
		TableRow headerRow = new TableRow(this);
		headerRow.addView(new TextView(this));
		for (int i=0; i<numDays; i++) {
			TextView tv = new TextView(this);
			tv.setText("" + (i+1));
			tv.setTextSize(20f);
			tv.setGravity(Gravity.CENTER);
			headerRow.addView(tv);
		}
		meetingsLayout.addView(headerRow);
		
		periodHeaders = new TextView[3];
		checkboxes = new CheckBox[3][numDays];
		for (int r=0; r<3; r++) {
			TableRow row = new TableRow(this);
			TextView tv = new TextView(this);
			tv.setText("");
			tv.setTextSize(20f);
			periodHeaders[r] = tv;
			row.addView(tv);
			for (int c=0; c<numDays; c++) {
				if (r==0) meetingsLayout.setColumnStretchable(c+1, true);
				CheckBox cb = new CheckBox(this);
				cb.setVisibility(View.INVISIBLE);
				cb.setEnabled(false);
				cb.setGravity(Gravity.CENTER);
				checkboxes[r][c] = cb;
				row.addView(cb);
			}
			meetingsLayout.addView(row);
		}
	}
	
	public void onStart() {
		super.onStart();
		
		nameBox.addTextChangedListener(new TextWatcher() {
			public void beforeTextChanged(CharSequence s, int start, int count, int after) { }
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				if (s.toString().equals("")) setTitle("Add a Course");
				else setTitle(s.toString());
			}
			public void afterTextChanged(Editable s) { }
		});
		
		InputFilter filter = new InputFilter() {
			public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
				String after = dest.subSequence(0, dstart).toString() + source.subSequence(start, end).toString() + dest.subSequence(dend, dest.length()).toString();
				try {
					int period = Integer.parseInt(after);
					if (period > 0 && period <= numPeriods) {
						setupMeetingsLayout(period);
						return null;
					}
				} catch (NumberFormatException e) {
					if (after.equals("")) {
						setupMeetingsLayout(-1);
						return null;
					}
				}
				return dest.subSequence(dstart, dend);
			}
		};
		periodBox.setFilters(new InputFilter[] {filter});
		
		/*cab = this.startActionMode(new ActionMode.Callback() {
			public boolean onCreateActionMode(ActionMode mode, Menu menu) {
				//MenuInflater inflater = mode.getMenuInflater();
		        //inflater.inflate(R.menu.add_course, menu);
		        mode.setTitle("Add a Course");
				return true;
			}
			public void onDestroyActionMode(ActionMode mode) {
				//TODO save the course
				finish();
			}
			public boolean onPrepareActionMode(ActionMode mode, Menu menu) { return false; }
			public boolean onActionItemClicked(ActionMode mode, MenuItem item) { return false; }
		});*/
	}
	
	private void setupMeetingsLayout(int period) {
		for (int r=0; r<3; r++) {
			int thisPeriod = period+r-1;
			if (thisPeriod > 0 && thisPeriod <= numPeriods) periodHeaders[r].setText(getOrdinal(thisPeriod));
			else periodHeaders[r].setText("");
			for (int c=0; c<numDays; c++) {
				if (thisPeriod > 0 && thisPeriod <= numPeriods) {
					checkboxes[r][c].setEnabled(true);
					checkboxes[r][c].setVisibility(View.VISIBLE);
				} else {
					checkboxes[r][c].setChecked(false);
					checkboxes[r][c].setEnabled(false);
					checkboxes[r][c].setVisibility(View.INVISIBLE);
				}
			}
		}
	}
	
	private static String getOrdinal(int num) {
		String suffix = "";
		if (num%10==1) suffix="st";
		else if (num%10==2) suffix="nd";
		else if (num%10==3) suffix="rd";
		else suffix = "th";
		return num+suffix;
	}
	
	public boolean onCreateOptionsMenu(Menu menu) {
		this.getMenuInflater().inflate(R.menu.add_course, menu);
		return true;
	}
	
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.action_delete) {
			//TODO delete the course
			finish();
			return true;
		} else if (item.getItemId() == R.id.action_done) {
			//TODO save the course
			finish();
			return true;
		}
		return false;
	}
}
