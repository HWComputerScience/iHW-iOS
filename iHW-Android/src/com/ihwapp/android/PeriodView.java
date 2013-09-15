package com.ihwapp.android;

import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

import com.ihwapp.android.model.Curriculum;
import com.ihwapp.android.model.Date;
import com.ihwapp.android.model.Day;
import com.ihwapp.android.model.Note;
import com.ihwapp.android.model.Period;
import com.ihwapp.android.model.Time;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.*;
import android.os.Parcelable;
import android.support.v4.app.Fragment;
import android.text.*;
import android.util.AttributeSet;
import android.util.SparseArray;
import android.view.*;
import android.view.inputmethod.EditorInfo;
import android.widget.*;

public class PeriodView extends LinearLayout implements DayFragment.OnFragmentVisibilityChangedListener {
	public static final int SIZE_MEDIUM = 18;
	public static final int SIZE_LARGE = 24;
	
	private Period period;
	private LinearLayout notesLayout;
	private boolean bottomIsEmpty = true;
	private boolean isVisible;
	private PopupMenu popupMenu;
	boolean changesSaved = true;
	private TextView countdownView;
	private Timer countdownTimer;

	public PeriodView(Context context) {
		super(context);
		this.initialize(context);
	}
	
	public PeriodView(Context context, AttributeSet attrs) {
		super(context, attrs);
		this.initialize(context);
	}
	
	public PeriodView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		this.initialize(context);
	}
	
	private void initialize(Context context) {
		this.setOrientation(LinearLayout.HORIZONTAL);
		LayoutInflater.from(context).inflate(R.layout.view_period, this, true);
		((TextView)this.findViewById(R.id.text_periodnum)).setTypeface(Typeface.SERIF, Typeface.BOLD);
		notesLayout = new LinearLayout(context);
		notesLayout.setOrientation(LinearLayout.VERTICAL);
		((LinearLayout)this.findViewById(R.id.layout_right)).addView(notesLayout);
		countdownView = ((TextView)this.findViewById(R.id.text_countdown));
	}
	
	public void setPeriod(Period p) {
		this.period = p;
		if (this.period.getIndex() >= 0) {
			if (this.period.getNum() > 0) {
				((TextView)this.findViewById(R.id.text_periodnum)).setText(getOrdinal(p.getNum()));
			}
			((TextView)this.findViewById(R.id.text_starttime)).setText(this.period.getStartTime().toString12());
			((TextView)this.findViewById(R.id.text_endtime)).setText(this.period.getEndTime().toString12());
		} else {
			((LinearLayout)this.findViewById(R.id.layout_left)).setVisibility(View.GONE);
		}
		((TextView)this.findViewById(R.id.text_title)).setText(this.period.getName());
		for (Note n : this.period.getNotes()) {
			addAnotherNoteBox(n);
		}
		addAnotherNoteBox(null);
	}
	
	protected void dispatchRestoreInstanceState(SparseArray<Parcelable> container) { }
	
	private void addAnotherNoteBox(Note n) {
		View v = LayoutInflater.from(this.getContext()).inflate(R.layout.view_note, null);
		int id = Resources.getSystem().getIdentifier("btn_check_holo_light", "drawable", "android");
		((CheckBox)v.findViewById(R.id.checkbox)).setButtonDrawable(id);
		((CheckBox)v.findViewById(R.id.checkbox)).setOnCheckedChangeListener(new CheckBox.OnCheckedChangeListener() {
			public void onCheckedChanged(CompoundButton arg0, boolean arg1) { changesSaved = false; }
		});
		EditText et = ((EditText)v.findViewById(R.id.text_note));
		et.setTextSize(SIZE_MEDIUM);
		et.setHorizontallyScrolling(false);
		et.setMaxLines(Integer.MAX_VALUE);
		//noteViews.add(v);
		notesLayout.addView(v);
		((TextView)v.findViewById(R.id.text_bullet)).setTextColor(Color.LTGRAY);
		
		if (n==null) bottomIsEmpty = true;
		else {
			((EditText)v.findViewById(R.id.text_note)).setText(n.getText());
			if (!n.getText().equals("")) ((TextView)v.findViewById(R.id.text_bullet)).setTextColor(Color.BLACK);
			if (n.isToDo()) {
				((CheckBox)v.findViewById(R.id.checkbox)).setVisibility(View.VISIBLE);
				v.findViewById(R.id.text_bullet).setVisibility(View.GONE);
			}
			((CheckBox)v.findViewById(R.id.checkbox)).setChecked(n.isChecked());
			if (n.isImportant()) makeImportant(notesLayout.getChildCount()-1);
			//v.findViewById(R.id.button_note_settings).setVisibility(View.VISIBLE);
			bottomIsEmpty = false;
		}

		NoteTextWatcher ntw = new NoteTextWatcher(v);
		((EditText)v.findViewById(R.id.text_note)).addTextChangedListener(ntw);
		((EditText)v.findViewById(R.id.text_note)).setOnEditorActionListener(ntw);
		((EditText)v.findViewById(R.id.text_note)).setOnFocusChangeListener(ntw);
		((Button)v.findViewById(R.id.button_note_settings)).setOnClickListener(new OptionsMenuListener(v));
	}
	
	private void removeNoteBox(int index) {
		//noteViews.remove(index);
		notesLayout.removeViewAt(index);
	}
	
	private void makeImportant(int index) {
		View row = notesLayout.getChildAt(index);
        EditText et = (EditText)row.findViewById(R.id.text_note);
		et.setTextSize(SIZE_LARGE);
		et.setTextColor(getResources().getColor(R.drawable.dark_red));
		et.setTypeface(Typeface.DEFAULT_BOLD);
		if (et.getText().toString().equals("")) return;
		removeNoteBox(index);
		//noteViews.add(0, row);
		notesLayout.addView(row, 0);
		changesSaved = false;
	}
	
	private void makeUnimportant(int index) {
		View row = notesLayout.getChildAt(index);
		EditText et = (EditText)row.findViewById(R.id.text_note);
		et.setTextSize(SIZE_MEDIUM);
		et.setTextColor(getResources().getColor(android.R.color.background_dark));
		et.setTypeface(Typeface.DEFAULT);
		if (et.getText().toString().equals("")) return;
		removeNoteBox(index);
		if (bottomIsEmpty) {
			//noteViews.add(noteViews.size()-1, row);
			notesLayout.addView(row, notesLayout.getChildCount()-1);
		} else {
			//noteViews.add(row);
			notesLayout.addView(row);
		}
		changesSaved = false;
	}
	
	private void saveNotes() {
		if (changesSaved) return;
		//Log.d("iHW", "Saving notes for period at: " + this.period.getDate() + ":" + this.period.getIndex());
		ArrayList<Note> notes = new ArrayList<Note>(notesLayout.getChildCount());
		for (int i=0; i<notesLayout.getChildCount(); i++) {
			View v = notesLayout.getChildAt(i);
			String text = ((EditText)v.findViewById(R.id.text_note)).getText().toString();
			boolean isToDo = ((CheckBox)v.findViewById(R.id.checkbox)).getVisibility()==View.VISIBLE;
			boolean isChecked = ((CheckBox)v.findViewById(R.id.checkbox)).isChecked();
			boolean isImportant = pixelsToSp(getContext(), ((EditText)v.findViewById(R.id.text_note)).getTextSize()) == SIZE_LARGE;
			if (!text.equals("")) {
				Note n = new Note(text, isToDo, isChecked, isImportant);
				notes.add(n);
			}
		}
		this.period.setNotes(notes);
		this.period.saveNotes();
		changesSaved = true;
	}
	
	public void addCountdownTimerIfNeeded() {
		if (this.period.getIndex() == -1) return;
		if (this.period.getDate().equals(new Date())) {
			Time now = new Time();
			int secondsUntil = now.secondsUntil(this.period.getStartTime());
			Day d = Curriculum.getCurrentCurriculum().getDay(this.period.getDate());
			if (secondsUntil > 0 &&
				((this.period.getIndex() > 0 && d.getPeriods().get(this.period.getIndex()-1).getStartTime().secondsUntil(now) > 0)
				|| (this.period.getIndex() == 0 && secondsUntil < 60*60))) {
				countdownView.setVisibility(View.VISIBLE);
				if (countdownTimer != null) countdownTimer.cancel();
				countdownTimer = new Timer();
				countdownTimer.scheduleAtFixedRate(new TimerTask() {
					public void run() {
						((Activity)PeriodView.this.getContext()).runOnUiThread(new Runnable() {
							public void run() {
								int secsUntil = new Time().secondsUntil(period.getStartTime());
								if (secsUntil >= 0) {
									String secs = "" + secsUntil%60;
									if (secsUntil%60 < 10) secs = "0" + secs;
									countdownView.setText("Starts in " + secsUntil/60 + ":" + secs);
								} else {
									PeriodView.this.findViewById(R.id.text_countdown).setVisibility(View.GONE);
									countdownTimer.cancel();
									countdownView.setVisibility(View.GONE);
									countdownTimer = null;
								}
							}
						});
					}
				}, 0, 1000);
			}
		}
	}
	
	public void onFragmentVisibilityChanged(Fragment f, boolean isVisible) {
		if (this.isVisible && !isVisible) {
			saveNotes();
		}
		this.isVisible = isVisible;
	}
	
	protected void dispatchSaveInstanceState(SparseArray<Parcelable> container) { }
	
	private class NoteTextWatcher implements TextWatcher, EditText.OnEditorActionListener, View.OnFocusChangeListener {
		private final View noteRow;
		
		public NoteTextWatcher(View v) {
			noteRow = v;
		}
		
		public int getIndex() {
			return notesLayout.indexOfChild(noteRow);
		}
		
		@Override
		public void onFocusChange(View tv, boolean hasFocus) {
			if (!hasFocus) {
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.GONE);
				if (popupMenu != null) popupMenu.dismiss();
				if (((EditText)tv).getText().toString().equals("") && getIndex() < notesLayout.getChildCount()-1) {
					removeNoteBox(getIndex());
				} else if (((EditText)tv).getText().toString().equals("")) {
					makeUnimportant(getIndex());
					((CheckBox)noteRow.findViewById(R.id.checkbox)).setVisibility(View.GONE);
					noteRow.findViewById(R.id.text_bullet).setVisibility(View.VISIBLE);
					((CheckBox)noteRow.findViewById(R.id.checkbox)).setChecked(false);
				} else saveNotes();
			} else {
				if (!((EditText)tv).getText().toString().equals("")) {
					noteRow.findViewById(R.id.button_note_settings).setVisibility(View.VISIBLE);
				}
			}
		}
		
		@Override
		public void afterTextChanged(Editable text) {
			changesSaved = false;
			EditText tv = (EditText)noteRow.findViewById(R.id.text_note);
			if (!text.toString().equals("")) {
				((TextView)noteRow.findViewById(R.id.text_bullet)).setTextColor(Color.BLACK);
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.VISIBLE);
				if (getIndex()==notesLayout.getChildCount()-1) bottomIsEmpty = false;
				if (!bottomIsEmpty) addAnotherNoteBox(null);
				tv.requestFocus();
			} else {
				((TextView)noteRow.findViewById(R.id.text_bullet)).setTextColor(Color.LTGRAY);
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.GONE);
				if (popupMenu != null) popupMenu.dismiss();
				if (getIndex()==notesLayout.getChildCount()-2 && bottomIsEmpty) {
					removeNoteBox(notesLayout.getChildCount()-1);
					notesLayout.getChildAt(notesLayout.getChildCount()-1).findViewById(R.id.text_note).requestFocus();
				}
			}
		}

		public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) { }
		public void onTextChanged(CharSequence s, int start, int before, int count) { }

		@Override
		public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
			if (actionId == EditorInfo.IME_ACTION_DONE) {
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.GONE);
				if (popupMenu != null) popupMenu.dismiss();
			}
			return false;
		}
	}
	
	private class OptionsMenuListener implements OnClickListener, PopupMenu.OnMenuItemClickListener {
		final View noteRow;
		
		public OptionsMenuListener(View v) {
			noteRow = v;
		}
		
		public int getIndex() {
			return notesLayout.indexOfChild(noteRow);
		}
		
		public void onClick(View v) {
			if (popupMenu != null) popupMenu.dismiss();
			popupMenu = new PopupMenu(getContext(), v);
			popupMenu.getMenuInflater().inflate(R.menu.popup_note, popupMenu.getMenu());
			popupMenu.setOnMenuItemClickListener(this);
			CheckBox cb = ((CheckBox)noteRow.findViewById(R.id.checkbox));
			MenuItem toDoItem = ((MenuItem)popupMenu.getMenu().findItem(R.id.option_is_todo));
			if (cb.getVisibility() == View.VISIBLE) toDoItem.setTitle(R.string.option_hide_checkbox);
			else toDoItem.setTitle(R.string.option_show_checkbox);
			MenuItem importantItem = ((MenuItem)popupMenu.getMenu().findItem(R.id.option_is_important));
			if (pixelsToSp(getContext(), ((EditText)noteRow.findViewById(R.id.text_note)).getTextSize()) == SIZE_MEDIUM) importantItem.setTitle(R.string.option_mark_important);
			else importantItem.setTitle(R.string.option_mark_unimportant);
			popupMenu.show();
		}

		@Override
		public boolean onMenuItemClick(MenuItem item) {
			changesSaved = false;
			if (item.getItemId() == R.id.option_is_todo) {
				CheckBox cb = ((CheckBox)noteRow.findViewById(R.id.checkbox));
				if (cb.getVisibility() == View.GONE) {
					cb.setVisibility(View.VISIBLE);
					noteRow.findViewById(R.id.text_bullet).setVisibility(View.GONE);
				} else {
					cb.setVisibility(View.GONE);
					noteRow.findViewById(R.id.text_bullet).setVisibility(View.VISIBLE);
				}
			} else if (item.getItemId() == R.id.option_is_important) {
				EditText et = ((EditText)noteRow.findViewById(R.id.text_note));
				if (pixelsToSp(getContext(), et.getTextSize()) == SIZE_MEDIUM) {
					makeImportant(getIndex());
				} else {
					makeUnimportant(getIndex());
				}
			}
			return false;
		}
	}
	
	public static float pixelsToSp(Context context, Float px) {
	    float scaledDensity = context.getResources().getDisplayMetrics().scaledDensity;
	    return px/scaledDensity;
	}
	
	private static String getOrdinal(int num) {
		String suffix;
		if (num%10==1) suffix="st";
		else if (num%10==2) suffix="nd";
		else if (num%10==3) suffix="rd";
		else suffix = "th";
		return num+suffix;
	}
}
