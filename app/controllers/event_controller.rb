class EventController < DialTestController
  attr_accessor :event

  MIN = 0
  MAX = 10

  def viewDidLoad
    super

    self.title = event[:name]

    build_dividers

    add_gradients

    self.view.addSubview(bar)

    self.view.addSubview(label)

    @last_timestamp = 0
    @old_value      = 0

    @tilt_manager = CMMotionManager.alloc.init

    handle_pause
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

        if divider_number != @old_value
          reposition_bar(divider_number + 1)
          submit_feedback("#{array[divider_number][1]}", Time.now.utc)
        end

        @old_value = divider_number
      end

      @last_timestamp = motion.timestamp
    end
  end

  def reposition_bar(divider_number)
    new_y_origin       = bar_position(divider_number)
    new_frame          = bar.frame
    new_frame.origin.y = new_y_origin
    bar.frame          = new_frame
  end

  def submit_feedback(value, timestamp)
    data = {
      'response[event_id]' => event[:id],
      'response[user_id]'  => current_user_id,
      'response[value]'    => value,
      'response[time]'     => timestamp,
      'user[api_token]'    => current_user_api_token
    }

    AFMotion::Client.shared.post("events/#{event[:id]}/responses", data) do |result|
      if result.success?
        parsed_string = result.object
      elsif result.failure?
        label.text = "#{result.error.localizedDescription}"
      end
    end
  end

  def label
    @label ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.frame = CGRect.new([20, 100], [self.view.frame.size.width - 40, 40])
      l.font  = UIFont.systemFontOfSize(12)
      l.numberOfLines = 0
      l.lineBreakMode = UILineBreakModeWordWrap
    end
  end

  def bar
    @bar ||= UIView.alloc.initWithFrame(CGRectZero).tap do |b|
      b.frame = CGRect.new([0, bar_position(6)], [self.view.frame.size.width, 5])
      b.backgroundColor = UIColor.blackColor
    end
  end

  def build_dividers
    MIN.upto(MAX) do |n|
      frame = CGRect.new([0, (n * divider_height) + height], [self.view.frame.size.width, divider_height])

      divider_view = UIView.alloc.initWithFrame(frame)

      divider_label           = UILabel.alloc.initWithFrame(frame)
      divider_label.text      = "#{array[n][1]}"
      divider_label.textColor = UIColor.whiteColor
      divider_label.font      = UIFont.boldSystemFontOfSize(25)
      divider_label.sizeToFit
      divider_label.center    = [self.view.frame.size.width / 2, divider_view.frame.size.height / 2]

      divider_view.addSubview(divider_label)

      self.view.addSubview(divider_view)
    end
  end

  def divider_height
    @divider_height ||= (self.view.frame.size.height - height) / (MAX + 1)
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

  def add_gradients
    gradient_frame_height  = (self.view.frame.size.height - height)
    half_of_middle_divider = (divider_height / 2)

    green  = UIColor.colorWithRed(40.0/255.0, green: 193.0/255.0, blue: 0.0/255.0, alpha: 1.0).CGColor
    yellow = UIColor.yellowColor.CGColor
    red    = UIColor.redColor.CGColor

    green_gradient         = CAGradientLayer.layer
    green_gradient.frame   = CGRect.new([0, height], [self.view.frame.size.width, (gradient_frame_height / 2) - half_of_middle_divider])
    green_gradient.colors  = [green, yellow]

    yellow_y_origin        = green_gradient.frame.origin.y + green_gradient.frame.size.height
    yellow_gradient        = CAGradientLayer.layer
    yellow_gradient.frame  = CGRect.new([0, yellow_y_origin], [self.view.frame.size.width, divider_height])
    yellow_gradient.colors = [yellow, yellow]

    red_y_origin           = yellow_gradient.frame.origin.y + divider_height
    red_gradient           = CAGradientLayer.layer
    red_gradient.frame     = CGRect.new([0, red_y_origin], [self.view.frame.size.width, (gradient_frame_height / 2) - half_of_middle_divider])
    red_gradient.colors    = [yellow, red]

    self.view.layer.insertSublayer(green_gradient, atIndex: 0)
    self.view.layer.insertSublayer(yellow_gradient, atIndex: 0)
    self.view.layer.insertSublayer(red_gradient, atIndex: 0)
  end

  def shaking?
    @shaking
  end

  def motionEnded(motion, withEvent:event)
    @shaking = motion == UIEventSubtypeMotionShake
    handle_pause
  end

  def handle_pause
    if paused_alert_showing?
      paused_alert.removeFromSuperview
      start_updates
    else
      stop_updates
      self.view.addSubview(paused_alert)
      paused_alert.addSubview(paused_label)
    end
  end

  def paused_alert
    @paused_alert ||= UIView.alloc.initWithFrame(CGRectZero).tap do |pa|
      pa.frame              = CGRect.new(
        [20, (self.view.bounds.size.height / 2) - 40],
        [self.view.frame.size.width - 40, 80]
      )
      pa.backgroundColor    = UIColor.colorWithRed(50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 0.95)
      pa.layer.cornerRadius = 5.0
      pa.sizeToFit
    end
  end

  def paused_label
    @paused_label ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |pl|
      pl.frame = CGRect.new(
        [5, 5], [paused_alert.frame.size.width - 10, paused_alert.frame.size.height - 10]
      )
      pl.font          = UIFont.systemFontOfSize(14)
      pl.numberOfLines = 0
      pl.lineBreakMode = UILineBreakModeWordWrap
      pl.color         = UIColor.whiteColor
      pl.text          = "#{event[:name]} is paused. Shake again to dismiss."
      pl.sizeToFit
      pl.textAlignment = UITextAlignmentCenter
      pl.center = [paused_alert.frame.size.width / 2, paused_alert.frame.size.height / 2]
    end
  end

  def start_updates
    if @tilt_manager.isDeviceMotionAvailable
      queue = NSOperationQueue.alloc.init

      device_motion_handler = lambda do |motion, error|
        reposition_bar_and_submit(motion, error)
      end

      @tilt_manager.deviceMotionUpdateInterval = 1.0/60.0

      @tilt_manager.startDeviceMotionUpdatesToQueue(queue, withHandler: device_motion_handler)
    else
      label.text = "Device Motion is unavailable in iOS simulator. Run `rake device` instead."
    end
  end

  def stop_updates
    if @tilt_manager.isDeviceMotionAvailable
      @tilt_manager.stopDeviceMotionUpdates
    else
      label.text = "Device Motion is off but unavailable. Run `rake device` instead."
    end
  end

  def paused_alert_showing?
    self.view.subviews.include?(paused_alert)
  end

end