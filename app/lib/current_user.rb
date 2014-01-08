module CurrentUser
  def current_user
    @current_user ||= NSUserDefaults.standardUserDefaults["current_user"] rescue nil
  end

  def current_user_api_token
    @current_user_api_token ||= current_user["api_token"] rescue nil
  end

  def current_user_id
    @current_user_id ||= current_user["id"] rescue nil
  end
end