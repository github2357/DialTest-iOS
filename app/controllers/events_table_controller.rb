class EventsTableController < DialTestController
  def viewDidLoad
    self.title = "Events"

    self.view.addSubview(table)

    control_view.addSubview(control)
    self.navigationItem.titleView = control_view

    new_button = UIBarButtonItem.alloc.initWithTitle("New", style: UIBarButtonItemStyleBordered, target:self, action:'new_event')
    self.navigationItem.rightBarButtonItem = new_button

    @data = []
    fetch_events("all")

    table.dataSource = self
    table.delegate = self

    table.addSubview(refresh)
  end

  def new_event
    controller        = NewEventController.alloc.init
    controller.parent = self
    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(controller),
      animated:true,
      completion: lambda {}
    )
  end

  def fetch_events(subset)
    if subset == "all"
      endpoint = "events"
    elsif subset == "mine"
      endpoint = "users/#{current_user_id}/user_events"
    end

    data = {
      'user[api_token]'    => current_user_api_token
    }

    AFMotion::Client.shared.get(endpoint, data) do |result|
      if result.success?
        @data = result.object
        table.reloadData
      end
    end
  end

  def control
    @control ||= UISegmentedControl.alloc.initWithItems(control_items).tap do |c|
      c.selectedSegmentIndex = 0
      c.setWidth(85.0, forSegmentAtIndex:0)
      c.setWidth(85.0, forSegmentAtIndex:1)
      c.addTarget(self, action:'control_change', forControlEvents:UIControlEventValueChanged)
    end
  end

  def control_view
    @control_view ||= UIView.alloc.initWithFrame(CGRectZero).tap do |cv|
      cv.frame = CGRect.new(
        [((self.view.frame.size.width - control.size.width) / 2), 0],
        [control.size.width, control.size.height]
      )
    end
  end

  def control_items
    @control_items ||= ["All Events", "My Events"]
  end

  def table
    @table ||= UITableView.alloc.initWithFrame(CGRectZero).tap do |t|
      t.frame            = self.view.bounds
      t.autoresizingMask = UIViewAutoresizingFlexibleHeight
      t.rowHeight        = 50
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if @data.first.is_a?(Hash)
      event                = @data[indexPath.row]
      controller           = EventController.alloc.initWithNibName(nil, bundle:nil)
      controller.event     = event
      self.navigationController.pushViewController(controller, animated:true)
    end
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "EventTableCell"

    event = @data[indexPath.row]

    if @data.first.is_a?(String)
      cell                      = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault,reuseIdentifier:@reuseIdentifier)
      cell.textLabel.text       = event
      cell.detailTextLabel.text = nil
    elsif @data.first.is_a?(Hash)
      cell        = EventCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)
      cell.event  = event
      cell.parent = self
      cell.build
    end

    cell.selectionStyle = UITableViewCellSelectionStyleGray

    cell
  end

  def tableView(tableView, heightForFooterInSection: section)
    0.01
  end

  def tableView(tableView, viewForFooterInSection: section)
    UIView.new
  end

  def control_change
    case selected_control_label
    when "All Events"
      fetch_events("all")
    when "My Events"
      fetch_events("mine")
    end
  end

  def selected_control_label
    control.titleForSegmentAtIndex(control.selectedSegmentIndex)
  end

  def refresh
    @refresh ||= UIRefreshControl.alloc.init.tap do |r|
      r.addTarget(self, action:'refresh_events', forControlEvents:UIControlEventValueChanged)
    end
  end

  def refresh_events
    control_change
    refresh.endRefreshing
  end
end