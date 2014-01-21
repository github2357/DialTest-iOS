class PickerView < UIView
  include CurrentUser

  attr_accessor :data, :checked_row, :parent

  def initWithFrame(frame)
    super

    self.layer.cornerRadius = 5.0

    self
  end

  def data=(data)
    @data = data
  end

  def parent=(parent)
    @parent = parent
  end

  def build_table
    self.addSubview(table)

    table.layer.cornerRadius = 5.0

    table.tableHeaderView = table_header
    table_header.addSubview(selection_notice)

    table.dataSource = self
    table.delegate   = self

    table.layoutIfNeeded
  end

  def table
    @table ||= UITableView.alloc.initWithFrame(CGRectZero).tap do |t|
      t.frame = CGRect.new(
        [0,0],
        [self.frame.size.width, self.frame.size.height]
      )
      t.layer.cornerRadius = 2.0
      t.backgroundColor    = UIColor.colorWithRed(50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 0.99)
      t.autoresizingMask   = UIViewAutoresizingFlexibleHeight
      t.rowHeight          = 40
    end
  end

  def table_header
    table_header_frame = CGRect.new(
      [self.frame.origin.x, self.frame.origin.y],
      [self.frame.size.width, 70]
    )
    @table_header ||= UIView.alloc.initWithFrame(table_header_frame)
  end

  def selection_notice
    @selection_notice ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |sn|
      sn.frame         = CGRect.new(
        [15, 10],
        [table_header.frame.size.width - 30, table_header.frame.size.height]
      )
      sn.font          = UIFont.systemFontOfSize(15)
      sn.text          = "#{data[:affiliation_description]}"
      sn.color         = UIColor.whiteColor
      sn.lineBreakMode = UILineBreakModeWordWrap
      sn.numberOfLines = 0
      sn.sizeToFit
    end
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.reloadData
    cell = tableView.cellForRowAtIndexPath(indexPath)
    cell.accessoryType = UITableViewCellAccessoryCheckmark
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    category = data[:affiliations][indexPath.row]
    create_event_participant(category)

    self.checked_row = indexPath.row
  end

  def tableView(tableView, numberOfRowsInSection: section)
    data[:affiliations].length
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"

    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier)
    cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)

    affiliation = data[:affiliations][indexPath.row]

    cell                = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault,reuseIdentifier:@reuseIdentifier)
    cell.textLabel.text = "#{affiliation}"
    cell.textLabel.font = UIFont.systemFontOfSize(13)

    cell
  end

  def tableView(tableView, heightForFooterInSection: section)
    0.01
  end

  def tableView(tableView, viewForFooterInSection: section)
    UIView.new
  end

  def tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    cell.textLabel.textColor = UIColor.whiteColor
    cell.backgroundColor = UIColor.colorWithRed(50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 0)
    cell.backgroundView = nil
    cell.selectedBackgroundView = nil
  end

  def create_event_participant(category_name)
    data = {
      'user[api_token]' => current_user_api_token,
      'id'              => @data[:id],
      'affiliation'     => "#{category_name}"
    }

    AFMotion::Client.shared.post("event_participants", data) do |result|
      if result.success?
        self.removeFromSuperview
        parent.handle_pause
      else
        # put_join_button_on_top
      end
    end
  end

end