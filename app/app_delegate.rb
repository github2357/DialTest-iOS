class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # dialtestapp.herokuapp.com
    AFMotion::Client.build_shared("http://localhost:3000/api/v1/") do
      header "Accept", "application/json"
      response_serializer :json
    end

    slide = SlideController.alloc.initWithNibName(nil, bundle: nil)
    slide_nav_controller = UINavigationController.alloc.initWithRootViewController(slide)

    @window ||= UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @window.makeKeyAndVisible

    @window.rootViewController = slide_nav_controller

    true
  end

end
