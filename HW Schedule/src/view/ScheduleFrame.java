package view;

import javax.swing.*;

public class ScheduleFrame extends JFrame {
	private static final long serialVersionUID = -8726369403910041693L;
	
	private ScheduleViewDelegate delegate;
	private ScheduleViewDataSource dataSource;
	
	public ScheduleFrame() {
		this.setVisible(true);
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.validate();
	}

	public ScheduleViewDelegate getDelegate() { return delegate; }
	public void setDelegate(ScheduleViewDelegate delegate) { this.delegate = delegate; }

	public ScheduleViewDataSource getDataSource() { return dataSource; }
	public void setDataSource(ScheduleViewDataSource dataSource) { this.dataSource = dataSource; }
}
