class DialTestController < UIViewController
  include CurrentUser

  def viewDidLoad
    super

  end

  def delegate
    @delegate ||= UIApplication.sharedApplication.delegate
  end

  def window
    @window ||= delegate.window
  end

  def development?
    RUBYMOTION_ENV == "development"
  end

  def height
    return 0 if self.navigationController.nil?
    nav_bar_height = self.navigationController.navigationBar.frame.size.height
    status_height  = UIApplication.sharedApplication.statusBarFrame.size.height

    @height ||= nav_bar_height + status_height
  end

  def alert(title=nil, message)
    alert = UIAlertView.alloc.initWithTitle(title,
      message:message,
      delegate:nil,
      cancelButtonTitle:"OK",
      otherButtonTitles:nil
    )
    alert.show
    p alert
  end
end