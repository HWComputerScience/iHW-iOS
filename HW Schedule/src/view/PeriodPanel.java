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
		int height = p.getStartTime().minutesUntil(p.getEndTime())*2;
		this.setMinimumSize(new Dimension(200,height));
		this.setPreferredSize(new Dimension(0,height));
		this.setMaximumSize(new Dimension(Short.MAX_VALUE,height));
		this.setBorder(BorderFactory.createLineBorder(Color.BLACK));
		this.setBackground(Color.WHITE);
	}
	
	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		g.setFont(new Font("Georgia", Font.PLAIN, 12));
		int startTimeWidth = g.getFontMetrics().stringWidth(p.getStartTime().toString12());
		int endTimeWidth = g.getFontMetrics().stringWidth(p.getEndTime().toString12());
		g.setColor(Color.LIGHT_GRAY);
		g.fillRect(0, 0, startTimeWidth+8, 18);
		g.fillRect(0, this.getHeight()-7-12, endTimeWidth+8, 18);
		g.setColor(Color.BLACK);
		g.drawRect(0, 0, startTimeWidth+8, 18);
		g.drawRect(0, this.getHeight()-7-12, endTimeWidth+8, 18);
		g.drawString(p.getStartTime().toString12(), 4, 14);
		g.drawString(p.getEndTime().toString12(), 4, this.getHeight()-6);
		g.setFont(new Font("Georgia", Font.BOLD, 14));
		g.drawString(p.getName(), startTimeWidth+16, 14);
	}
}
