class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # dialtestapp.herokuapp.com
    AFMotion::Client.build_shared("http://localhost:3000/api/v1/") do
      header "Accept", "application/json"
      response_serializer :json
    end

    event = EventsTableController.alloc.initWithNibName(nil, bundle: nil)
    event_nav_controller = UINavigationController.alloc.initWithRootViewController(event)

    @window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @window.makeKeyAndVisible

    @window.rootViewController = event_nav_controller

    true
  end

end
