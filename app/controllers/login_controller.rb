class LoginController < DialTestController
  attr_accessor :email_field, :password_field

  DESIRED_FB_ATTRIBUTES = %w(basic_info email user_location user_birthday)

  def viewDidLoad
    NSNotificationCenter.defaultCenter.addObserver(self, selector:'handleKeyboardDidShow:', name:UIKeyboardDidShowNotification, object:nil)

    self.title = "DialTest"
    self.view.backgroundColor = UIColor.whiteColor

    self.view.addSubview(scroll)

    scroll.addSubview(field_views_background)
    field_views_background.addSubview(field_views_divider)
    field_views_background.addSubview(email_field)
    field_views_background.addSubview(password_field)
    scroll.addSubview(login_button)
    scroll.addSubview(signup_button)
    scroll.addSubview(fb_button)

    email_field.delegate    = self
    password_field.delegate = self
  end

  def textFieldShouldReturn(textField)
    if textField == email_field
      self.password_field.becomeFirstResponder
    elsif textField = password_field
      self.login
    end
    true
  end

  def field_views_background
    @field_views_background ||= UIView.alloc.initWithFrame(CGRect.new([40, 75],[235, 80])).tap do |view|
      view.backgroundColor  = UIColor.colorWithRed(235.0/255, green:235.0/255, blue:235.0/255, alpha:1)
      view.layer.cornerRadius = 2.0
      view.layer.borderWidth = 0.6
      view.layer.borderColor = UIColor.lightGrayColor.CGColor
      view.sizeToFit
    end
  end

  def field_views_divider
    @field_views_divider ||= UIView.alloc.initWithFrame(CGRect.new([0, 39.5],[235, 1])).tap do |divider|
      divider.backgroundColor  = UIColor.lightGrayColor
    end
  end

  def email_field
    @email_field ||= begin
      UITextField.alloc.initWithFrame(CGRectZero).tap do |field|
        field.borderStyle                   = UITextBorderStyleNone
        field.clearButtonMode               = UITextFieldViewModeWhileEditing
        field.placeholder                   = "Email"
        field.enablesReturnKeyAutomatically = true
        field.returnKeyType                 = UIReturnKeyNext
        field.keyboardType                  = UIKeyboardTypeEmailAddress
        field.autocorrectionType            = UITextAutocorrectionTypeNo
        field.autocapitalizationType        = UITextAutocapitalizationTypeNone
        field.sizeToFit
        field.frame                         = CGRect.new([8, 6],[self.view.frame.size.width - 100, 28])
      end
    end
  end

  def password_field
    @password_field ||= begin
      UITextField.alloc.initWithFrame(CGRectZero).tap do |field|
        field.borderStyle                   = UITextBorderStyleNone
        field.clearButtonMode               = UITextFieldViewModeWhileEditing
        field.placeholder                   = "Password"
        field.enablesReturnKeyAutomatically = true
        field.returnKeyType                 = UIReturnKeyGo
        field.autocapitalizationType        = UITextAutocapitalizationTypeNone
        field.secureTextEntry               = true
        field.sizeToFit
        field.frame                         = CGRect.new([8, 46],[self.view.frame.size.width - 100, 28])
      end
    end
  end

  def login_button
    @login_button ||= UIButton.buttonWithType(UIButtonTypeCustom).tap do |button|
      button.backgroundColor = UIColor.blueColor
      button.setTitle("Log In", forState:UIControlStateNormal)
      button.setTitleColor(UIColor.whiteColor, forState:UIControlStateNormal)
      button.sizeToFit
      button.frame = [
        [40, field_views_background.frame.origin.y + field_views_background.frame.size.height + 10],
        [235, 40]
      ]
      button.layer.cornerRadius = 2.0
      button.autoresizingMask =
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
      button.addTarget(self,
        action:"login",
        forControlEvents:UIControlEventTouchUpInside)
    end
  end

  def signup_button
    @signup_button ||= UIButton.buttonWithType(UIButtonTypeCustom).tap do |button|
      button.backgroundColor = UIColor.whiteColor
      button.font            = UIFont.boldSystemFontOfSize(15)
      button.setTitle("Create an Account", forState:UIControlStateNormal)
      button.setTitleColor(UIColor.blueColor, forState:UIControlStateNormal)
      button.sizeToFit
      button.frame = [
        [40, fb_button.frame.origin.y + fb_button.frame.size.height + 10],
        [235, 46]
      ]
      button.autoresizingMask   =
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
      button.addTarget(self,
        action:"signup",
        forControlEvents:UIControlEventTouchUpInside)
    end
  end

  def fb_button
    @fb_button ||= FBLoginView.alloc.initWithReadPermissions(DESIRED_FB_ATTRIBUTES).tap do |button|
      button.frame    = [
        [40, self.view.frame.size.height - (46 * 2) - 120],
        [235, 46]
      ]
      button.delegate = self
    end
  end

  def loginViewFetchedUserInfo(loginView, user: user)
    SVProgressHUD.show

    data = { 'user' => user }

    AFMotion::Client.shared.post("facebook_users", data ) do |result|
      if result.success?
        NSUserDefaults.standardUserDefaults["current_user"] = result.object
        window.rootViewController = delegate.events_nav_controller
        SVProgressHUD.dismiss
      else
        SVProgressHUD.dismiss
        alert("Log in Failed", result.object["errors"]) if result.object
      end
    end
  end

  def loginViewShowingLoggedInUser(loginView)
  end

  def loginViewShowingLoggedOutUser(loginView)
  end

  def loginView(loginView, handleError:error)
    if FBErrorUtility.shouldNotifyUserForError(error)
      alertTitle = "Facebook error"
      alertMessage = FBErrorUtility.userMessageForError(error)
    elsif FBErrorUtility.errorCategoryForError(error) == FBErrorCategoryAuthenticationReopenSession
      alertTitle = "Session Error"
      alertMessage = "Your current session is no longer valid. Please log in again."
    elsif FBErrorUtility.errorCategoryForError(error) == FBErrorCategoryUserCancelled
      alertTitle = "Whoops"
      alertMessage = "Looks like you cancelled Login. Try again."
    elsif error.fberrorShouldNotifyUser
      alertTitle = "Whoops!"
      alertMessage = error.fberrorUserMessage
    else
      alertTitle  = "Something went wrong"
      alertMessage = "Please try again later."
    end

    if (alertMessage)
      alert(alertTitle, alertMessage)
    end
  end

  def login
    SVProgressHUD.show

    data = {
      "user[email]"    => email_field.text,
      "user[password]" => password_field.text
    }

    AFMotion::Client.shared.post("sessions", data ) do |result|
      if result.success?
        NSUserDefaults.standardUserDefaults["current_user"] = result.object
        window.rootViewController = delegate.events_nav_controller
        SVProgressHUD.dismiss
      else
        SVProgressHUD.dismiss
        alert("Log in Failed", result.object["errors"])
      end
    end
  end

  def scroll
    @scroll ||= UIScrollView.alloc.initWithFrame(self.view.bounds).tap do |scroll|
      scroll.bounces               = true
      scroll.delegate              = self
      scroll.alwaysBounceVertical  = true
    end
  end

  def handleKeyboardDidShow(selector)
    scroll.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 120)
  end

  def viewWillDisappear(animated)
    super

    NSNotificationCenter.defaultCenter.removeObserver(self)

    self.view = nil

    @email_field = nil
    @password_field = nil
    @field_views_background = nil
    @field_views_divider = nil
  end

  def signup
    controller        = SignUpController.alloc.init
    self.presentViewController(
      UINavigationController.alloc.initWithRootViewController(controller),
      animated:true,
      completion: lambda {}
    )
  end
end