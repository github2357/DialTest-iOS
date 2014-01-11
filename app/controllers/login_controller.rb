class LoginController < DialTestController
  def viewDidLoad
    self.title = "Login"
    self.view.backgroundColor = UIColor.whiteColor

    self.view.addSubview(field_views_background)
    self.view.addSubview(field_views_divider)
    self.view.addSubview(email_field)
    self.view.addSubview(password_field)
    self.view.addSubview(login_button)
  end

  def textFieldShouldReturn(textField)
    if textField == email_field
      self.password_field.becomeFirstResponder
    elsif textField = password_field
      self.signin(login_button)
    end
    true
  end

  def field_views_background
    @field_views_background ||= UIView.alloc.initWithFrame(CGRect.new([40, 155],[235, 80])).tap do |view|
      view.backgroundColor  = UIColor.colorWithRed(235.0/255, green:235.0/255, blue:235.0/255, alpha:1)
      view.layer.cornerRadius = 2.0
      view.layer.borderWidth = 0.6
      view.layer.borderColor = UIColor.lightGrayColor.CGColor
      view.sizeToFit
    end
  end

  def field_views_divider
    @field_views_divider ||= UIView.alloc.initWithFrame(CGRect.new([40, 195],[235, 1])).tap do |divider|
      divider.backgroundColor  = UIColor.lightGrayColor
    end
  end

  def email_field
    @email_field ||= begin
      UITextField.alloc.initWithFrame(CGRectZero).tap do |field|
        field.borderStyle = UITextBorderStyleNone
        field.clearButtonMode = UITextFieldViewModeWhileEditing
        field.placeholder = "Email"
        field.enablesReturnKeyAutomatically = true
        field.returnKeyType = UIReturnKeyNext
        field.keyboardType = UIKeyboardTypeEmailAddress
        field.autocapitalizationType = UITextAutocapitalizationTypeNone
        field.sizeToFit
        field.frame = CGRect.new( [50, 162],[self.view.frame.size.width - 100, 28] )
      end
    end
  end

  def password_field
    @password_field ||= begin
      UITextField.alloc.initWithFrame(CGRectZero).tap do |field|
        field.borderStyle = UITextBorderStyleNone
        field.clearButtonMode = UITextFieldViewModeWhileEditing
        field.placeholder = "Password"
        field.enablesReturnKeyAutomatically = true
        field.returnKeyType = UIReturnKeyGo
        field.autocapitalizationType = UITextAutocapitalizationTypeNone
        field.secureTextEntry = true
        field.sizeToFit
        field.frame = CGRect.new( [50, 202],[self.view.frame.size.width - 100, 28] )
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
        action:"login:",
        forControlEvents:UIControlEventTouchUpInside)
    end
  end

  def login(sender)
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
        alert(result.object["errors"])
      end
    end
  end


end