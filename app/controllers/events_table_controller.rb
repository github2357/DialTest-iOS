class EventsTableController < DialTestController
  attr_accessor :callbacks

  def viewDidLoad
    self.title = "Events"

    self.view.addSubview(table)

    control_view.addSubview(control)
    self.navigationItem.titleView = control_view

    new_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target:self, action: 'new_event')
    self.navigationItem.rightBarButtonItem = new_button

    settings_button = UIBarButtonItem.alloc.initWithImage(UIImage.imageNamed("profile_icon.png"), style: UIBarButtonItemStyleBordered, target:self, action:'settings')
    self.navigationItem.leftBarButtonItem = settings_button

    @data = []
    @callbacks = {}

    reset_page_variables

    fetch_events("all")

    @callbacks[:all_events_scroll] = lambda {
      page = @all_events_page
      fetch_events("all", page, true) if @data.lastObject
    }

    @callbacks[:my_events_scroll] = lambda {
      page = @my_events_page
      fetch_events("mine", page, true) if @data.lastObject
    }

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

  def fetch_events(subset, page=nil, scrolling=false)
    SVProgressHUD.show

    if subset == "all"
      endpoint = "events"
    elsif subset == "mine"
      endpoint = "users/#{current_user_id}/user_events"
    end

    data = {
      'user[api_token]' => current_user_api_token,
      'page'            => page
    }

    AFMotion::Client.shared.get(endpoint, data) do |result|
      if result.success?
        if scrolling
          @data += result.object
        else
          @data = result.object
        end
        table.reloadData
        SVProgressHUD.dismiss
      else
        SVProgressHUD.dismiss
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
    reset_page_variables

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

  def leave_event(sender)
    position   = sender.convertPoint(CGPointZero, toView: table)
    index_path = table.indexPathForRowAtPoint(position)
    event      = @data[index_path.row]

    data = {
      'user[api_token]'    => current_user_api_token
    }

    AFMotion::Client.shared.delete("event_participants/#{event[:id]}", data) do |result|
      if result.success?
        sender.removeFromSuperview
        reset_page_variables
        fetch_events("all")
        table.reloadData
      else
      end
    end
  end

  def settings
    controller = SettingsController.alloc.initWithNibName(nil, bundle:nil)
    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(controller),
      animated:true,
      completion: lambda {}
    )
  end

  def reset_page_variables
    @all_events_page = 1
    @my_events_page  = 1
  end

  def scrollViewDidEndDragging(scrollView, willDecelerate:decelerate)
    if scrolling("All Events") && hit_bottom?(scrollView) && !@callbacks[:all_events_scroll].nil?
      @all_events_page += 1
      @callbacks[:all_events_scroll].call()
    elsif scrolling("My Events") && hit_bottom?(scrollView) && !@callbacks[:my_events_scroll].nil?
      @my_events_page += 1
      @callbacks[:my_events_scroll].call()
    end
  end

  def scrolling(control_title)
    if selected_control_label == control_title
      true
    else
      false
    end
  end

end