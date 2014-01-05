class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    AFMotion::Client.build_shared("#{RMENV['host']}/#{RMENV['api_version']}") do
      header "Accept", "application/json"
      response_serializer :json
    end

    window.makeKeyAndVisible

    if NSUserDefaults.standardUserDefaults["current_user"]
      window.rootViewController = events_nav_controller
    else
      window.rootViewController = login_nav_controller
    end

    true
  end

  def window
    @window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
  end

  def with_navigation
    UINavigationController.alloc.initWithRootViewController(yield)
  end

  def events_nav_controller
    @events_nav_controller ||= begin
      with_navigation do
        @events ||= EventsTableController.alloc.initWithNibName(nil, bundle: nil)
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

end