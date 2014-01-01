class SlideController < UIViewController

  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.whiteColor

    self.title = "WHAT"

    build_dividers

    self.view.addSubview(bar)

    self.view.addSubview(label)

    @last_timestamp = 0

    @tilt_manager = CMMotionManager.alloc.init

    if @tilt_manager.isDeviceMotionAvailable
      queue = NSOperationQueue.alloc.init

      device_motion_handler = lambda do |motion, error|
        submit_position(motion, error)
      end

      @tilt_manager.deviceMotionUpdateInterval = 1.0/60.0

      label.text = "About to start updates"

      @tilt_manager.startDeviceMotionUpdatesToQueue(queue, withHandler: device_motion_handler)
    else
      label.text = "Nothing available. Are you in simulator?"
    end

  end

  def submit_position(motion, error)
    Dispatch::Queue.main.sync do

      elapsed_time = motion.timestamp - @last_timestamp

      if (@last_timestamp > 0)
        divider_number     = (motion.attitude.pitch * 10).round
        label.text = "#{divider_number}"
        new_y_origin       = bar_position(divider_number)
        new_frame          = bar.frame
        new_frame.origin.y = new_y_origin
        bar.frame          = new_frame

        submit_feedback("#{divider_number}")
      end

      @last_timestamp = motion.timestamp
    end
  end

  def slide
    @slide ||= UISlider.alloc.initWithFrame(CGRectZero).tap do |s|
      s.frame = CGRect.new([20, 150], [self.view.frame.size.width - 40, 40])
      s.minimumValue = 0
      s.maximumValue = 10
      s.addTarget(self, action: "slidetastic", forControlEvents: UIControlEventValueChanged)
    end
  end

  def submit_feedback(value)
    data = {
      'response[event_id]' => 1,
      'response[user_id]'  => 3,
      'response[value]'    => value,
      'user[api_token]'    => "1cfc0f51520db5a3f5dfebb8bd437618"
    }
    AFMotion::Client.shared.post("events/1/responses", data) do |result|
      parsed_string = result.object
      if result.success?
        p parsed_string
      end
    end
  end

  def label
    @label ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.frame = CGRect.new([20, 100], [self.view.frame.size.width - 40, 40])
    end
  end

  def bar
    @bar ||= UIView.alloc.initWithFrame(CGRectZero).tap do |b|
      b.frame = CGRect.new([0, bar_position(10)], [self.view.frame.size.width, 5])
      b.backgroundColor = UIColor.blackColor
    end
  end

  def build_dividers
    array = (1..10).to_a

    1.upto(10) do |n|
      frame = CGRect.new([0, (n * divider_height) + 10], [self.view.frame.size.width, divider_height])
      divider_view = UIView.alloc.initWithFrame(frame)
      divider_view.backgroundColor  = UIColor.colorWithRed(235.0/255, green:235.0/255, blue:235.0/255, alpha:1)
      divider_view.layer.borderWidth = 0.5
      divider_view.layer.borderColor = UIColor.lightGrayColor.CGColor

      divider_label           = UILabel.alloc.initWithFrame(frame)
      divider_label.text      = "#{array[-n]}"
      divider_label.textColor = UIColor.darkGrayColor
      divider_label.font      = UIFont.systemFontOfSize(20)
      divider_label.sizeToFit
      divider_label.center    = [self.view.frame.size.width / 2, divider_view.frame.size.height / 2]

      divider_view.addSubview(divider_label)

      self.view.addSubview(divider_view)
    end
  end

  def divider_height
    @divider_height ||= (self.view.frame.size.height - height) / 10
  end

  def height
    nav_bar_height = self.navigationController.navigationBar.frame.size.height
    status_height  = UIApplication.sharedApplication.statusBarFrame.size.height

    @height ||= nav_bar_height + status_height
  end

  def bar_position(divider_number)
    divider = (divider_number * divider_height) + divider_height + 10
    divider - (divider_height / 2)
  end

end