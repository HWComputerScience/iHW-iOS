package model;

import org.json.*;

public class Note {
	private String text;
	private boolean isToDo;
	private boolean checked;
	
	public Note(String text, boolean isToDo, boolean checked) {
		this.text = text;
		this.isToDo = isToDo;
		this.checked = checked;
	}
	
	public Note(JSONObject obj) {
		this(obj.getString("text"), obj.getBoolean("isToDo"), obj.getBoolean("isChecked"));
	}
	
	public JSONObject saveNote() {
		JSONObject obj = new JSONObject();
		obj.put("text", text);
		obj.put("isToDo", isToDo);
		obj.put("isChecked", checked);
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
}
