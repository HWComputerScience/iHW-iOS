package com.ihwapp.android.model;

import org.json.*;

import android.os.Parcel;
import android.os.Parcelable;

public class Note implements Parcelable {
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
	
	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(text);
		dest.writeInt(isToDo ? 1 : 0);
		dest.writeInt(checked ? 1 : 0);
		dest.writeInt(isImportant ? 1 : 0);
	}
	
	public static final Parcelable.Creator<Note> CREATOR = new Parcelable.Creator<Note>() {
		public Note createFromParcel(Parcel in) {
		    return new Note(in);
		}
		
		public Note[] newArray(int size) {
		    return new Note[size];
		}
	};
	
	public Note(Parcel in) {
		this(in.readString(), (in.readInt()==1), (in.readInt()==1), (in.readInt()==1));
	}
	
}
