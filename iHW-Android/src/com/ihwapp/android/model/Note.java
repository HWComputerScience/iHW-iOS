package com.ihwapp.android.model;

import org.json.*;

public class Note {
	private String text;
	private boolean isToDo;
	private boolean checked;
	private boolean isImportant;
	
	public Note(String text, boolean isToDo, boolean checked, boolean isImportant) {
		this.text = text;
		this.isToDo = isToDo;
		this.checked = checked;
		this.isImportant = isImportant;
	}
	
	public Note(JSONObject obj) {
		try {
			this.text = obj.getString("text");
			this.isToDo = obj.getBoolean("isToDo");
			this.checked = obj.getBoolean("isChecked");
			this.isImportant = obj.getBoolean("isImportant");
		} catch (JSONException e) {}
	}
	
	public JSONObject saveNote() {
		JSONObject obj = new JSONObject();
		try {
			obj.put("text", text);
			obj.put("isToDo", isToDo);
			obj.put("isChecked", checked);
			obj.put("isImportant", isImportant);
		} catch (JSONException e) {}
		return obj;
	}
	
	public boolean equals(Object other) {
		if (other instanceof Note && this.text.equals(((Note)other).text)) return true;
		return false;
	}
	
	public String toString() {
		return text;
	}
	
	public void setText(String newText) { this.text = newText; }
	public String getText() { return text; }
	public boolean isToDo() { return isToDo; }
	public boolean isChecked() { return checked; }
	public boolean isImportant() { return isImportant; }
}
