package model;

import org.json.*;

public class Note {
	private String text;
	private boolean isToDo;
	
	public Note(String text, boolean isToDo) {
		this.text = text;
		this.isToDo = isToDo;
	}
	
	public Note(JSONObject obj) {
		//TODO: load from JSON object
	}
	
	public JSONObject saveNote() {
		//TODO: save to JSON object
		return null;
	}
	
	public boolean equals(Object other) {
		if (other instanceof Note && this.text.equals(((Note)other).text)) return true;
		return false;
	}
	
	public void setText(String newText) { this.text = newText; }
	public String getText() { return text; }
	public boolean isToDo() { return isToDo; }	
}
