package general;

import view.HomepageFrame;

public class Controller {
	public static void main(String[] args) {
		new Controller();
	}
	
	public Controller() {
		showHomepage();
	}
	
	public void showHomepage() {
		new HomepageFrame();
	}
}
