class DialTestController < UIViewController

  def current_user
    @current_user ||= NSUserDefaults.standardUserDefaults["current_user"] rescue nil
  end

  def current_user_api_token
    @current_user_api_token ||= current_user["api_token"] rescue nil
  end

  def current_user_id
    @current_user_id ||= current_user["id"] rescue nil
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

end