class SettingsController < DialTestController
  include CurrentUser

  NON_DISPLAY_KEYS = %w(id api_token facebook_profile)

  def viewDidLoad
    super

    self.title = "Settings"
    self.view.backgroundColor = UIColor.whiteColor

    cancel_button = UIBarButtonItem.alloc.initWithTitle("Cancel", style: UIBarButtonItemStyleBordered, target:self, action:'cancel')
    self.navigationItem.leftBarButtonItem = cancel_button

    self.view.addSubview(table)
  end

  def fb_logout_button
    @fb_logout_button ||= FBLoginView.alloc.initWithReadPermissions(LoginController::DESIRED_FB_ATTRIBUTES).tap do |button|
      button.frame = [
        [0, 0],
        [235, 46]
      ]
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
        [0, 0],
        [235, 40]
      ]
      button.layer.cornerRadius = 2.0
      button.autoresizingMask =
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
      button.addTarget(self,
        action:"logout",
        forControlEvents:UIControlEventTouchUpInside)
    end

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
end