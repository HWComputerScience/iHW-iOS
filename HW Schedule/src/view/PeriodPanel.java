package view;

import java.util.List;
import java.awt.*;

import javax.swing.BorderFactory;
import javax.swing.JPanel;

import model.Period;

public class PeriodPanel extends JPanel {
	private static final long serialVersionUID = -3652755502045723337L;
	private Period p;
	
	public PeriodPanel(Period p, List<String> bodyLines) {
		this.p=p;
		this.setPreferredSize(new Dimension(0,p.getStartTime().minutesUntil(p.getEndTime())*2));
		this.setBorder(BorderFactory.createLineBorder(Color.BLACK));
	}
	
	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		double leftSideWidth = this.getWidth() * 0.4;
		double rightSideWidth = this.getWidth() * 0.6;
		g.setFont(new Font("Georgia", Font.PLAIN, 12));
		g.drawString(p.getStartTime().toString12(), 4, 12);
		g.drawString(p.getEndTime().toString12(), 4, this.getHeight()-5);
	}
}
