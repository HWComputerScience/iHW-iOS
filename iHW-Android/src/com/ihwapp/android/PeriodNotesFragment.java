package com.ihwapp.android;

import java.util.*;

import com.ihwapp.android.model.Curriculum;
import com.ihwapp.android.model.Date;
import com.ihwapp.android.model.Note;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.*;
import android.util.Log;
import android.view.*;
import android.view.View.OnClickListener;
import android.view.inputmethod.*;
import android.widget.*;

public class PeriodNotesFragment extends Fragment implements DayFragment.OnFragmentVisibilityChangedListener {
	public static final int SIZE_MEDIUM = 18;
	public static final int SIZE_LARGE = 24;
	
	private Date d;
	private int period;
	private ArrayList<Note> notes;
	private ArrayList<View> noteViews;
	private LinearLayout notesLayout;
	private boolean bottomIsEmpty = true;
	private boolean isVisible;
	private PopupMenu popupMenu;
	boolean handlersAreValid;
	boolean changesSaved = true;

	public static PeriodNotesFragment newInstance(Date d, int period) {
		PeriodNotesFragment fragment = new PeriodNotesFragment();
		Bundle args = new Bundle();
		args.putString("date", d.toString());
		args.putInt("period", period);
		fragment.setArguments(args);
		return fragment;
	}
	public PeriodNotesFragment() { }

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (getArguments() != null) {
			d = new Date(getArguments().getString("date"));
			period = getArguments().getInt("period");
		}
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		notesLayout = new LinearLayout(getActivity());
		notesLayout.setOrientation(LinearLayout.VERTICAL);
		return notesLayout;
	}
	
	public void onStart() {
		super.onStart();
		notes = Curriculum.getCurrentCurriculum().getNotes(d, period);
		//Log.d("iHW", "####### notes == null: " + (notes==null));
		noteViews = new ArrayList<View>(notes.size()+6);
		notesLayout.removeAllViews();
		for (Note n : notes) {
			addAnotherNoteBox(n);
		}
		addAnotherNoteBox(null);
	}
	
	public void onResume() {
		super.onResume();
		handlersAreValid = true;
	}
	
	public void onPause() {
		super.onPause();
		handlersAreValid = false;
		saveNotes();
	}
	
	public void onDestroyView() {
		notesLayout.removeAllViews();
		noteViews = null;
		notesLayout = null;
		super.onDestroyView();
	}
	
	public void onFragmentVisibilityChanged(Fragment f, boolean isVisible) {
		if (this.isVisible && !isVisible) {
			saveNotes();
		}
		this.isVisible = isVisible;
	}
	
	
	private View addAnotherNoteBox(Note n) {
		View v = this.getLayoutInflater(null).inflate(R.layout.view_note, null);
		int id = Resources.getSystem().getIdentifier("btn_check_holo_light", "drawable", "android");
		((CheckBox)v.findViewById(R.id.checkbox)).setButtonDrawable(id);
		((CheckBox)v.findViewById(R.id.checkbox)).setOnCheckedChangeListener(new CheckBox.OnCheckedChangeListener() {
			public void onCheckedChanged(CompoundButton arg0, boolean arg1) { changesSaved = false; }
		});
		EditText et = ((EditText)v.findViewById(R.id.text_note));
		et.setTextSize(SIZE_MEDIUM);
		et.setHorizontallyScrolling(false);
		et.setMaxLines(Integer.MAX_VALUE);
		noteViews.add(v);
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
			if (n.isImportant()) makeImportant(noteViews.size()-1);
			//v.findViewById(R.id.button_note_settings).setVisibility(View.VISIBLE);
			bottomIsEmpty = false;
		}
		
		NoteTextWatcher ntw = new NoteTextWatcher(v);
		((EditText)v.findViewById(R.id.text_note)).addTextChangedListener(ntw);
		((EditText)v.findViewById(R.id.text_note)).setOnEditorActionListener(ntw);
		((EditText)v.findViewById(R.id.text_note)).setOnFocusChangeListener(ntw);
		((Button)v.findViewById(R.id.button_note_settings)).setOnClickListener(new OptionsMenuListener(v));
		return v;
	}
	
	private void removeNoteBox(int index) {
		noteViews.remove(index);
		notesLayout.removeViewAt(index);
	}
	
	private void makeImportant(int index) {
		View row = noteViews.get(index);
		EditText et = (EditText)row.findViewById(R.id.text_note);
		et.setTextSize(SIZE_LARGE);
		et.setTextColor(getResources().getColor(R.drawable.dark_red));
		et.setTypeface(Typeface.DEFAULT_BOLD);
		if (et.getText().toString().equals("")) return;
		removeNoteBox(index);
		noteViews.add(0, row);
		notesLayout.addView(row, 0);
		changesSaved = false;
	}
	
	private void makeUnimportant(int index) {
		View row = noteViews.get(index);
		EditText et = (EditText)row.findViewById(R.id.text_note);
		et.setTextSize(SIZE_MEDIUM);
		et.setTextColor(getResources().getColor(android.R.color.background_dark));
		et.setTypeface(Typeface.DEFAULT);
		if (et.getText().toString().equals("")) return;
		removeNoteBox(index);
		if (bottomIsEmpty) {
			noteViews.add(noteViews.size()-1, row);
			notesLayout.addView(row, notesLayout.getChildCount()-1);
		} else {
			noteViews.add(row);
			notesLayout.addView(row);
		}
		Log.d("iHW", "there are " + noteViews.size() + " views in the list.");
		changesSaved = false;
	}
	
	private void saveNotes() {
		if (changesSaved) return;
		notes = new ArrayList<Note>(noteViews.size());
		int ct=0;
		for (View v : noteViews) {
			String text = ((EditText)v.findViewById(R.id.text_note)).getText().toString();
			boolean isToDo = ((CheckBox)v.findViewById(R.id.checkbox)).getVisibility()==View.VISIBLE;
			boolean isChecked = ((CheckBox)v.findViewById(R.id.checkbox)).isChecked();
			boolean isImportant = pixelsToSp(getActivity(), ((EditText)v.findViewById(R.id.text_note)).getTextSize()) == SIZE_LARGE;
			if (!text.equals("")) {
				Note n = new Note(text, isToDo, isChecked, isImportant);
				notes.add(n);
				ct++;
			}
		}
		Log.d("iHW", "saved " + ct + " notes from " + d + ":" + period);
		Curriculum.getCurrentCurriculum().setNotes(d, period, notes);
		Curriculum.getCurrentCurriculum().saveCycle(d);
		changesSaved = true;
	}
	
	private class NoteTextWatcher implements TextWatcher, EditText.OnEditorActionListener, View.OnFocusChangeListener {
		private View noteRow;
		
		public NoteTextWatcher(View v) {
			noteRow = v;
		}
		
		public int getIndex() {
			return notesLayout.indexOfChild(noteRow);
		}
		
		@Override
		public void onFocusChange(View tv, boolean hasFocus) {
			if (!handlersAreValid) return;
			if (!hasFocus) {
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.GONE);
				if (popupMenu != null) popupMenu.dismiss();
				if (((EditText)tv).getText().toString().equals("") && getIndex() < noteViews.size()-1) {
					removeNoteBox(getIndex());
				} else if (((EditText)tv).getText().toString().equals("")) {
					makeUnimportant(getIndex());
					((CheckBox)noteRow.findViewById(R.id.checkbox)).setVisibility(View.GONE);
					noteRow.findViewById(R.id.text_bullet).setVisibility(View.VISIBLE);
					((CheckBox)noteRow.findViewById(R.id.checkbox)).setChecked(false);
				} else if (!((EditText)tv).getText().toString().equals("")) saveNotes();
			} else {
				if (!((EditText)tv).getText().toString().equals("")) {
					noteRow.findViewById(R.id.button_note_settings).setVisibility(View.VISIBLE);
				}
			}
		}
		
		@Override
		public void afterTextChanged(Editable text) {
			changesSaved = false;
			if (!handlersAreValid) return;
			EditText tv = (EditText)noteRow.findViewById(R.id.text_note);
			if (!text.toString().equals("")) {
				((TextView)noteRow.findViewById(R.id.text_bullet)).setTextColor(Color.BLACK);
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.VISIBLE);
				if (getIndex()==noteViews.size()-1) bottomIsEmpty = false;
				if (!bottomIsEmpty) addAnotherNoteBox(null);
				tv.requestFocus();
			} else {
				((TextView)noteRow.findViewById(R.id.text_bullet)).setTextColor(Color.LTGRAY);
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.GONE);
				if (popupMenu != null) popupMenu.dismiss();
				if (getIndex()==noteViews.size()-2 && bottomIsEmpty) {
					removeNoteBox(noteViews.size()-1);
					notesLayout.getChildAt(notesLayout.getChildCount()-1).findViewById(R.id.text_note).requestFocus();
				}
			}
		}

		public void beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3) { }
		public void onTextChanged(CharSequence s, int start, int before, int count) { }

		@Override
		public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
			if (!handlersAreValid) return false;
			if (actionId == EditorInfo.IME_ACTION_DONE) {
				noteRow.findViewById(R.id.button_note_settings).setVisibility(View.GONE);
				if (popupMenu != null) popupMenu.dismiss();
			}
			return false;
		}
	}
	
	private class OptionsMenuListener implements OnClickListener, PopupMenu.OnMenuItemClickListener {
		View noteRow;
		
		public OptionsMenuListener(View v) {
			noteRow = v;
		}
		
		public int getIndex() {
			return notesLayout.indexOfChild(noteRow);
		}
		
		public void onClick(View v) {
			if (!handlersAreValid) return;
			if (popupMenu != null) popupMenu.dismiss();
			popupMenu = new PopupMenu(getActivity(), v);
			popupMenu.getMenuInflater().inflate(R.menu.popup_note, popupMenu.getMenu());
			popupMenu.setOnMenuItemClickListener(this);
			CheckBox cb = ((CheckBox)noteRow.findViewById(R.id.checkbox));
			MenuItem toDoItem = ((MenuItem)popupMenu.getMenu().findItem(R.id.option_is_todo));
			if (cb.getVisibility() == View.VISIBLE) toDoItem.setTitle(R.string.option_hide_checkbox);
			else toDoItem.setTitle(R.string.option_show_checkbox);
			MenuItem importantItem = ((MenuItem)popupMenu.getMenu().findItem(R.id.option_is_important));
			if (pixelsToSp(getActivity(), ((EditText)noteRow.findViewById(R.id.text_note)).getTextSize()) == SIZE_MEDIUM) importantItem.setTitle(R.string.option_mark_important);
			else importantItem.setTitle(R.string.option_mark_unimportant);
			popupMenu.show();
		}

		@Override
		public boolean onMenuItemClick(MenuItem item) {
			changesSaved = false;
			if (!handlersAreValid) return false;
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
				if (pixelsToSp(getActivity(), et.getTextSize()) == SIZE_MEDIUM) {
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
}
