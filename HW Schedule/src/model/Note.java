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
		//load from JSON object
	}
	
	public boolean equals(Object other) {
		if (other instanceof Note && this.text.equals(((Note)other).text)) return true;
		return false;
	}
	
	public String getText() { return text; }
	public boolean isToDo() { return isToDo; }	
}
