class AppDelegate
  include CurrentUser

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    if RMENV["API_ENV"] == "production"
      host = "#{RMENV['host']}"
    else
      host = "#{RMENV['host']}:9292"
    end

    AFMotion::Client.build_shared("http://#{host}/#{RMENV['api_version']}") do
      header "Accept", "application/json"
      response_serializer :json
    end

    tab_controller.viewControllers = [
      events_nav_controller, settings_nav_controller
    ]

    window.makeKeyAndVisible

    if current_user.nil?
      window.rootViewController = login_nav_controller
    else
      window.rootViewController = tab_controller
    end

    UINavigationBar.appearance.setTitleTextAttributes(
      { UITextAttributeTextColor => UIColor.whiteColor }
    )
    UINavigationBar.appearance.tintColor    = UIColor.whiteColor
    UINavigationBar.appearance.barTintColor = UIColor.colorWithRed(50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)

    # window.rootViewController.navigationBar.translucent  = true

    true
  end

  def window
    @window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
  end

  def with_navigation
    UINavigationController.alloc.initWithRootViewController(yield)
  end

  attr_accessor :login_nav_controller

  def tab_controller
    @tab_controller ||= TabController.alloc.initWithNibName(nil, bundle: nil)
  end

  def events_nav_controller
    @events_nav_controller ||= begin
      with_navigation do
        @events ||= EventsTableController.alloc.initWithNibName(nil, bundle: nil)
      end
    end
  end

  def settings_nav_controller
    @settings_nav_controller ||= begin
      with_navigation do
        @settings ||= SettingsController.alloc.initWithNibName(nil, bundle: nil)
      end
    end
  end

  def login_nav_controller
    @login_nav_controller ||= begin
      with_navigation do
        @login ||= LoginController.alloc.initWithNibName(nil, bundle: nil)
      end
    end
  end

  def application(application, openURL:url,
                  sourceApplication:sourceApplication,
                  annotation:annotation)
    was_handled = FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication)
  end

end