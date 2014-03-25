class SearchController < DialTestController
  include CurrentUser

  def loadView
    super

    search_controller.delegate = self
    search_controller.searchResultsDataSource = self
    search_controller.searchResultsDelegate = self
  end

  def viewDidLoad
    super

    self.title = "Search"

    cancel_button = UIBarButtonItem.alloc.initWithTitle("Cancel", style: UIBarButtonItemStyleBordered, target:self, action:'cancel')
    self.navigationItem.leftBarButtonItem = cancel_button

    @data = []

    search_bar.becomeFirstResponder

    self.view.addSubview(table)
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

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if @data.first.is_a?(Hash)
      event                = @data[indexPath.row]
      controller           = EventController.alloc.initWithNibName(nil, bundle:nil)
      controller.event     = event
      self.navigationController.pushViewController(controller, animated:true)
    end
  end

  def tableView(tableView, heightForFooterInSection: section)
    0.01
  end

  def tableView(tableView, viewForFooterInSection: section)
    UIView.new
  end

  def searchDisplayController(controller, didLoadSearchResultsTableView: tableView)
    tableView.rowHeight = 51
  end

  def searchBarTextDidBeginEditing(search_bar)
    search_bar.showsCancelButton = false
  end

  def searchBarCancelButtonClicked(search_bar)
    search_bar.resignFirstResponder
    search_bar.showsCancelButton = false
  end

  def searchDisplayController(controller, shouldReloadTableForSearchString: searchString)
    data = {
      'term'                   => searchString,
      'user[api_token]'        => current_user_api_token
    }

    AFMotion::Client.shared.get("event_searches", data ) do |result|
      if result.success?
        @data = result.object
      end

      controller.searchResultsTableView.reloadData
    end
  end

  def search_bar
    @search_bar ||= UISearchBar.alloc.initWithFrame(CGRectZero).tap do |bar|
      bar.frame = [
        [0,40],
        [self.view.frame.size.width - 10, 44]
      ]
      bar.barTintColor = UIColor.colorWithRed(75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
      bar.tintColor = UIColor.colorWithRed(75.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
      bar.translucent = true
      bar.placeholder = "Search Events"
      bar.delegate = self
    end
  end

  def search_controller
    @search_controller ||= UISearchDisplayController.alloc.initWithSearchBar(search_bar, contentsController: self)
  end

  def table
    @table ||= UITableView.alloc.initWithFrame(self.view.bounds).tap do |t|
      t.autoresizingMask      = UIViewAutoresizingFlexibleHeight
      t.rowHeight             = 51

      t.dataSource = self
      t.delegate = self

      t.tableHeaderView = search_bar
    end
  end

  def cancel
    self.dismissViewControllerAnimated(true, completion:lambda {})
  end
end