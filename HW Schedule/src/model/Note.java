package model;

public class Note {
	private String text;
	private boolean isToDo;
	
	public Note(String text, boolean isToDo) {
		this.text = text;
		this.isToDo = isToDo;
	}
	
	public boolean equals(Object other) {
		if (other instanceof Note && this.text.equals(((Note)other).text)) return true;
		return false;
	}
	
	public String getText() { return text; }
	public boolean isToDo() { return isToDo; }
	
}
