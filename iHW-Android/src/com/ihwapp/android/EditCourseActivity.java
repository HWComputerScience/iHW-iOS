package com.ihwapp.android;

import com.ihwapp.android.model.Course;
import com.ihwapp.android.model.Curriculum;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;
import android.text.*;
import android.view.*;
import android.view.inputmethod.InputMethodManager;
import android.widget.*;

public class EditCourseActivity extends Activity {
	private int numPeriods;
	private int numDays;
	private int period = -1;
	private int numMeetings = 0;
	private EditText nameBox;
	private EditText periodBox;
	private Spinner termSpinner;
	private TableLayout meetingsLayout;
	private CheckBox[][] meetingBoxes;
	private TextView[] periodHeaders;
	private String existingCourseName = null;
	
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		this.setContentView(R.layout.activity_edit_course);
		this.setTitle("Add a Course");
		getActionBar().setDisplayHomeAsUpEnabled(true);
		
		numDays = Curriculum.getCurrentCampus(this);
		numPeriods = numDays+3;
		nameBox = (EditText)this.findViewById(R.id.courseNameBox);
		periodBox = (EditText)this.findViewById(R.id.coursePeriodBox);
		termSpinner = (Spinner)this.findViewById(R.id.courseTermBox);
		int etid = Resources.getSystem().getIdentifier("edit_text_holo_light", "drawable", "android");
		nameBox.setBackgroundResource(etid);
		periodBox.setBackgroundResource(etid);
		ArrayAdapter<CharSequence> a = ArrayAdapter.createFromResource(this, R.array.term_options, R.layout.spinner_layout);
		a.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		termSpinner.setAdapter(a);
		
		TableRow.LayoutParams labelParams = new TableRow.LayoutParams(); 
		labelParams.gravity = Gravity.CENTER_VERTICAL;
		TableRow.LayoutParams cbParams = new TableRow.LayoutParams(TableRow.LayoutParams.WRAP_CONTENT, TableRow.LayoutParams.WRAP_CONTENT); 
		cbParams.gravity = Gravity.CENTER_HORIZONTAL;
		cbParams.leftMargin = 4;
		cbParams.rightMargin = -4;
		
		//setup class meetings UI
		meetingsLayout = (TableLayout)this.findViewById(R.id.courseMeetingsLayout);
		meetingsLayout.setPadding(10, 0, 10, 0);
		
		//setup header rows of meetings UI
		TableRow headerRow = new TableRow(this);
		headerRow.addView(new TextView(this));
		TextView heading = new TextView(this);
		heading.setText("Day");
		heading.setGravity(Gravity.CENTER);
		TableRow.LayoutParams headingParams = new TableRow.LayoutParams();
		headingParams.span = numDays;
		headerRow.addView(heading, headingParams);
		meetingsLayout.addView(headerRow);
		
		TableRow headerRow2 = new TableRow(this);
		headerRow2.addView(new TextView(this));
		for (int i=0; i<numDays; i++) {
			TextView tv = new TextView(this);
			tv.setText("" + (i+1));
			tv.setTextSize(20f);
			tv.setGravity(Gravity.CENTER);
			headerRow2.addView(tv);
		}
		meetingsLayout.addView(headerRow2);
		
		//setup other rows of meetings UI
		periodHeaders = new TextView[3];
		meetingBoxes = new CheckBox[3][numDays];
		for (int r=0; r<3; r++) {
			TableRow row = new TableRow(this);
			//setup row headers
			TextView periodHeader = new TextView(this);
			periodHeader.setText("");
			periodHeader.setWidth(70);
			periodHeader.setLayoutParams(labelParams);
			periodHeader.setTextSize(20f);
			periodHeaders[r] = periodHeader;
			row.addView(periodHeader);
			//setup checkboxes
			for (int c=0; c<numDays; c++) {
				if (r==0) meetingsLayout.setColumnStretchable(c+1, true);
				CheckBox cb = new CheckBox(this);
				int cbid = Resources.getSystem().getIdentifier("btn_check_holo_light", "drawable", "android");
				cb.setButtonDrawable(cbid);
				cb.setVisibility(View.INVISIBLE);
				cb.setEnabled(false);
				cb.setLayoutParams(cbParams);
				meetingBoxes[r][c] = cb;
				cb.setTag(new int[] {r,c});
				cb.setOnCheckedChangeListener(new DoublePeriodsEnforcer());
				row.addView(cb);
			}
			meetingsLayout.addView(row);
		}
		
		//make course title show up in action bar
		nameBox.addTextChangedListener(new TextWatcher() {
			public void beforeTextChanged(CharSequence s, int start, int count, int after) { }
			public void onTextChanged(CharSequence s, int start, int before, int count) {
				if (s.toString().equals("")) setTitle("Add a Course");
				else setTitle(s.toString());
			}
			public void afterTextChanged(Editable s) { }
		});
		
		//filter input in period box
		InputFilter filter = new PeriodBoxFilter();
		periodBox.setFilters(new InputFilter[] {filter});
	}
	
	protected void onStart() {
		super.onStart();
		existingCourseName = getIntent().getStringExtra("courseName");
		if (existingCourseName != null) {
			this.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
			Course c = Curriculum.getCurrentCurriculum(this).getCourse(existingCourseName);
			getActionBar().setTitle(c.getName());
			nameBox.setText(c.getName());
			periodBox.setText("" + c.getPeriod());
			termSpinner.setSelection(c.getTerm());
			for (int i=1; i<=numDays; i++) {
				if (c.getMeetingOn(i) == Constants.MEETING_SINGLE_PERIOD) meetingBoxes[1][i-1].setChecked(true);
				else if (c.getMeetingOn(i) == Constants.MEETING_DOUBLE_BEFORE) {
					meetingBoxes[0][i-1].setChecked(true);
					meetingBoxes[1][i-1].setChecked(true);
				} else if (c.getMeetingOn(i) == Constants.MEETING_DOUBLE_AFTER) {
					meetingBoxes[1][i-1].setChecked(true);
					meetingBoxes[2][i-1].setChecked(true);
				}
			}
		}
	}
	
	private void setupMeetingsLayout(int pd) {
		this.period = pd;
		LinearLayout meetingsContainer = (LinearLayout)this.findViewById(R.id.courseMeetingsContainer);
		if (period == -1) meetingsContainer.setVisibility(View.GONE);
		else meetingsContainer.setVisibility(View.VISIBLE);
		this.numMeetings = 0;
		this.invalidateOptionsMenu();
		for (int r=0; r<3; r++) {
			int thisPeriod = period+r-1;
			if (thisPeriod > 0 && thisPeriod <= numPeriods) periodHeaders[r].setText(getOrdinal(thisPeriod));
			else periodHeaders[r].setText("");
			for (int c=0; c<numDays; c++) {
				if (thisPeriod > 0 && thisPeriod <= numPeriods) {
					meetingBoxes[r][c].setEnabled(true);
					meetingBoxes[r][c].setVisibility(View.VISIBLE);
				} else {
					meetingBoxes[r][c].setChecked(false);
					meetingBoxes[r][c].setEnabled(false);
					meetingBoxes[r][c].setVisibility(View.INVISIBLE);
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
		this.getMenuInflater().inflate(R.menu.edit_course, menu);
		return true;
	}
	
	public boolean onPrepareOptionsMenu(Menu menu) {
		MenuItem doneItem = menu.findItem(R.id.action_done);
		//doneItem.setEnabled(numMeetings>0);
		if (doneItem.isEnabled()) doneItem.setIcon(R.drawable.ic_action_done);
		else doneItem.setIcon(R.drawable.ic_action_done_disabled);
		return true;
	}
	
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getItemId() == R.id.action_delete) {
			if (existingCourseName != null) {
				Curriculum c = Curriculum.getCurrentCurriculum(this);
				c.removeCourse(c.getCourse(existingCourseName));
				Curriculum.save(this);
			}
			finish();
			return true;
		} else if (item.getItemId() == R.id.action_done || item.getItemId() == android.R.id.home) {
			if (numMeetings>0 && !nameBox.getText().toString().equals("")) {
				Curriculum c = Curriculum.getCurrentCurriculum(this);
				int[] meetings = new int[numDays];
				for (int i=0; i<numDays; i++) {
					if (!meetingBoxes[1][i].isChecked()) meetings[i] = Constants.MEETING_X_DAY;
					else if (meetingBoxes[0][i].isChecked()) meetings[i] = Constants.MEETING_DOUBLE_BEFORE;
					else if (meetingBoxes[2][i].isChecked()) meetings[i] = Constants.MEETING_DOUBLE_AFTER;
					else meetings[i] = Constants.MEETING_SINGLE_PERIOD;
				}
				boolean success;
				Course toAdd = new Course(nameBox.getText().toString(), period, termSpinner.getSelectedItemPosition(), meetings);
				if (existingCourseName != null) success = c.replaceCourse(existingCourseName, toAdd);
				else success = c.addCourse(toAdd);
				if (!success) {
					Toast.makeText(this, "The course meetings you selected conflict with one or more of your other courses. Please change them and try again.", Toast.LENGTH_LONG).show();
				} else {
					Curriculum.save(this);
					if (item.getItemId() == android.R.id.home) {
						Toast.makeText(this, "Course saved.", Toast.LENGTH_SHORT).show();
					}
					finish();
				}
			} else {
				if (item.getItemId() == android.R.id.home) {
					Toast.makeText(this, "Changes discarded.", Toast.LENGTH_SHORT).show();
					finish();
				} else {
					Toast.makeText(this, "The course must have a name and at least one class meeting.", Toast.LENGTH_SHORT).show();
				}
			}
			return true;
		}
		return false;
	}
	
	public void onBackPressed() {
		Toast.makeText(this, "Changes discarded.", Toast.LENGTH_SHORT).show();
		super.onBackPressed();
	}
	
	private class PeriodBoxFilter implements InputFilter {
		public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
			String after = dest.subSequence(0, dstart).toString() + source.subSequence(start, end).toString() + dest.subSequence(dend, dest.length()).toString();
			try {
				int period = Integer.parseInt(after);
				if (period > 0 && period <= numPeriods) {
					setupMeetingsLayout(period);
					InputMethodManager imm = (InputMethodManager)getSystemService(
						      Context.INPUT_METHOD_SERVICE);
						imm.hideSoftInputFromWindow(periodBox.getWindowToken(), 0);
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
	}
	
	private class DoublePeriodsEnforcer implements CheckBox.OnCheckedChangeListener {
		public void onCheckedChanged(CompoundButton cb, boolean isChecked) {
			if (isChecked) numMeetings++;
			else numMeetings--;
			int r = ((int[])cb.getTag())[0];
			int c = ((int[])cb.getTag())[1];
			if (r==1 && !isChecked) {
				meetingBoxes[0][c].setChecked(false);
				meetingBoxes[2][c].setChecked(false);
			} else if (r!=1 && isChecked) {
				if (r==0 && meetingBoxes[2][c].isChecked()) meetingBoxes[2][c].setChecked(false);
				if (r==2 && meetingBoxes[0][c].isChecked()) meetingBoxes[0][c].setChecked(false);
				meetingBoxes[1][c].setChecked(true);
			}
			invalidateOptionsMenu();
		}
	}
}
