class SettingsController < DialTestController
  include CurrentUser

  NON_DISPLAY_KEYS = %w(id api_token facebook_profile)

  def viewDidLoad
    super

    self.title = "Account"
    self.view.backgroundColor = UIColor.whiteColor

    cancel_button = UIBarButtonItem.alloc.initWithTitle("Cancel", style: UIBarButtonItemStyleBordered, target:self, action:'cancel')
    self.navigationItem.leftBarButtonItem = cancel_button

    self.view.addSubview(table)
  end

  def fb_logout_button
    @fb_logout_button ||= FBLoginView.alloc.initWithReadPermissions(LoginController::DESIRED_FB_ATTRIBUTES).tap do |button|
      button.frame = [
        [(235 - (self.view.frame.size.width / 2)) / 2, 0],
        [235, 46]
      ]
      button.layer.borderColor = UIColor.colorWithRed(59.0/255.0, green: 87.0/255.0, blue: 157.0/255.0, alpha: 1.0)
      button.delegate = self
    end
  end

  def logout_button
    @logout_button ||= UIButton.buttonWithType(UIButtonTypeCustom).tap do |button|
      button.backgroundColor = UIColor.blueColor
      button.setTitle("Log Out", forState:UIControlStateNormal)
      button.setTitleColor(UIColor.whiteColor, forState:UIControlStateNormal)
      button.sizeToFit
      button.frame = [
        [(235 - (self.view.frame.size.width / 2)) / 2, 0],
        [235, 46]
      ]
      button.layer.cornerRadius = 2.0
      button.autoresizingMask =
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
      button.addTarget(self,
        action:"logout",
        forControlEvents:UIControlEventTouchUpInside)
    end
  end

  def table
    @table ||= UITableView.alloc.initWithFrame(self.view.bounds, style: UITableViewStyleGrouped).tap do |t|
      t.autoresizingMask = UIViewAutoresizingFlexibleHeight
      t.dataSource       = self
      t.delegate         = self
      t.rowHeight        = 46
    end
  end

  def sections
    data.keys
  end

  def rows_for_section(section_index)
    data[self.sections[section_index]]
  end

  def row_for_index_path(index_path)
    rows_for_section(index_path.section)[index_path.row]
  end

  def tableView(tableView, titleForHeaderInSection:section)
    section == 0 ? sections[section] : nil
  end

  def numberOfSectionsInTableView(tableView)
    self.sections.count
  end

  def tableView(tableView, numberOfRowsInSection: section)
    rows_for_section(section).count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "SettingsCell"

    key, value = row_for_index_path(indexPath).first

    cell = SettingsCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:@reuseIdentifier)

    if indexPath.section == 0
      cell.key = key.capitalize
      cell.value = value
      cell.contentView.addSubview(cell.label)
      cell.contentView.addSubview(cell.content)
    elsif indexPath.section == 1
      if current_user["facebook_profile"]
        cell.contentView.backgroundColor = UIColor.colorWithRed(59.0/255.0, green: 87.0/255.0, blue: 157.0/255.0, alpha: 1.0)
        cell.contentView.addSubview(fb_logout_button)
      else
        cell.contentView.backgroundColor = UIColor.blueColor
        cell.contentView.addSubview(logout_button)
      end
    end

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  end

  def loginViewShowingLoggedOutUser(loginView)
    logout
  end

  def loginView(loginView, handleError:error)
    if FBErrorUtility.shouldNotifyUserForError(error)
      alertTitle = "Facebook error"
      alertMessage = FBErrorUtility.userMessageForError(error)
    elsif FBErrorUtility.errorCategoryForError(error) == FBErrorCategoryAuthenticationReopenSession
      alertTitle = "Session Error"
      alertMessage = "Your current session is no longer valid. Please log in again."
    elsif FBErrorUtility.errorCategoryForError(error) == FBErrorCategoryUserCancelled
      p "user cancelled login"
    elsif error.fberrorShouldNotifyUser
      alertTitle = "UH"
      alertMessage = error.fberrorUserMessage
    else
      alertTitle  = "Something went wrong"
      alertMessage = "Please try again later."
    end

    if (alertMessage)
      alert(alertTitle, alertMessage)
    end
  end

  def cancel
    self.dismissViewControllerAnimated(true, completion:lambda {})
  end

  def logout
    self.dismissViewControllerAnimated(true, completion:lambda {reset_root})
  end

  def reset_root
    remove_current_user
    window.rootViewController = delegate.login_nav_controller
  end

  def data
    new_hash = current_user.clone
    new_hash.reject!{ |k,v| NON_DISPLAY_KEYS.include?(k) }

    settings_hash = Hash.new
    settings_hash["Personal Information"] = new_hash.map{|k,v| {k=>v} }
    settings_hash["Logout"] = [{"logout" => "logout"}]
    settings_hash
  end
end