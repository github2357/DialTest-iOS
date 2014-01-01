class SlideController < UIViewController
  MIN = 0
  MAX = 10

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
        reposition_bar_and_submit(motion, error)
      end

      @tilt_manager.deviceMotionUpdateInterval = 1.0/60.0

      label.text = "About to start updates"

      @tilt_manager.startDeviceMotionUpdatesToQueue(queue, withHandler: device_motion_handler)
    else
      label.text = "Nothing available. Are you in simulator?"
    end

  end

  def reposition_bar_and_submit(motion, error)
    Dispatch::Queue.main.sync do

      elapsed_time = motion.timestamp - @last_timestamp

      if (@last_timestamp > 0)
        pitch_value = (motion.attitude.pitch * 10).round

        if pitch_value >= 10
          divider_number = MAX
        elsif pitch_value <= 0
          divider_number = MIN
        else
          divider_number = pitch_value
        end

        reposition_bar(divider_number + 1)
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

  def reposition_bar(divider_number)
    new_y_origin       = bar_position(divider_number)
    new_frame          = bar.frame
    new_frame.origin.y = new_y_origin
    bar.frame          = new_frame
  end

  def submit_feedback(value)
    data = {
      'response[event_id]' => 1,
      'response[user_id]'  => 3,
      'response[value]'    => array[value.to_i][1],
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
      b.frame = CGRect.new([0, bar_position(5)], [self.view.frame.size.width, 5])
      b.backgroundColor = UIColor.blackColor
    end
  end

  def build_dividers
    MIN.upto(MAX) do |n|
      frame = CGRect.new([0, (n * divider_height) + height], [self.view.frame.size.width, divider_height])
      divider_view = UIView.alloc.initWithFrame(frame)
      divider_view.backgroundColor  = UIColor.colorWithRed(235.0/255, green:235.0/255, blue:235.0/255, alpha:1)
      divider_view.layer.borderWidth = 0.5
      divider_view.layer.borderColor = UIColor.lightGrayColor.CGColor

      divider_label           = UILabel.alloc.initWithFrame(frame)
      divider_label.text      = "#{array[n][1]}"
      divider_label.textColor = UIColor.darkGrayColor
      divider_label.font      = UIFont.systemFontOfSize(20)
      divider_label.sizeToFit
      divider_label.center    = [self.view.frame.size.width / 2, divider_view.frame.size.height / 2]

      divider_view.addSubview(divider_label)

      self.view.addSubview(divider_view)
    end
  end

  def divider_height
    @divider_height ||= (self.view.frame.size.height - height) / (MAX + 1)
  end

  def height
    nav_bar_height = self.navigationController.navigationBar.frame.size.height
    status_height  = UIApplication.sharedApplication.statusBarFrame.size.height

    @height ||= nav_bar_height + status_height
  end

  def bar_position(divider_number)
    divider = (divider_number * divider_height) + height
    divider - (divider_height / 2)
  end

  def array
    @array ||= [
      [0, 5], [1, 4], [2, 3], [3, 2], [4, 1], [5, 0],
      [6, -1], [7, -2], [8, -3], [9, -4], [10, -5]
    ]
  end

end