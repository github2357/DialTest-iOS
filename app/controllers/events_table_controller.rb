class EventsTableController < UIViewController
  def viewDidLoad
    self.title = "Events"

    self.view.addSubview(table)

    @data = []
    fetch_events

    table.dataSource = self
    table.delegate = self
  end

  def fetch_events
    data = {
      'user[api_token]'    => "1cfc0f51520db5a3f5dfebb8bd437618"
    }
    AFMotion::Client.shared.get("events", data) do |result|
      if result.success?
        @data = result.object
        table.reloadData
      end
    end
  end

  def table
    @table ||= UITableView.alloc.initWithFrame(CGRectZero).tap do |t|
      t.frame            = self.view.bounds
      t.autoresizingMask = UIViewAutoresizingFlexibleHeight
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if @data.first.is_a?(Hash)
      event                = @data[indexPath.row]
      controller           = SlideController.alloc.initWithNibName(nil, bundle:nil)
      controller.event     = event
      self.navigationController.pushViewController(controller, animated:true)
    end
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "EventTableCell"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:@reuseIdentifier)
    end

    event = @data[indexPath.row]

    cell.selectionStyle = UITableViewCellSelectionStyleGray

    if @data.first.is_a?(String)
      cell.textLabel.text       = event
      cell.detailTextLabel.text = nil
    elsif @data.first.is_a?(Hash)
      cell.textLabel.text       = event[:name]
      cell.detailTextLabel.text = event[:ends_at]
      cell.detailTextLabel.font = UIFont.systemFontOfSize(13)
    end

    cell
  end

  def tableView(tableView, heightForFooterInSection: section)
    0.01
  end

  def tableView(tableView, viewForFooterInSection: section)
    UIView.new
  end
end