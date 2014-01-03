class DialTestController < UIViewController
  LOCAL_API_TOKEN = "1cfc0f51520db5a3f5dfebb8bd437618"
  PROD_API_TOKEN  = "6dc2db61053257032e0e1d8ccf22dc7a"
  API_TOKEN = "1cfc0f51520db5a3f5dfebb8bd437618"
  USER_ID = 3

  def api_token
    @api_token ||= PROD_API_TOKEN
  end

  def user_id
    @user_id ||= USER_ID
  end

  def height
    nav_bar_height = self.navigationController.navigationBar.frame.size.height
    status_height  = UIApplication.sharedApplication.statusBarFrame.size.height

    @height ||= nav_bar_height + status_height
  end

end