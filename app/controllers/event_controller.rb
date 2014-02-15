class EventController < DialTestController
  attr_accessor :event

  MIN = 0
  MAX = 10

  def viewDidLoad
    super

    get_event

    self.title = event[:name]

    build_dividers

    add_gradients

    self.view.addSubview(bar)

    self.view.addSubview(label)

    @event = []
    @last_timestamp = 0
    @old_value      = 0

    @tilt_manager = CMMotionManager.alloc.init

    @draggable = false

    determine_right_nav_button
  end

  def viewWillAppear(animated)
    reconnect
  end

  def reconnect
    @socket = AsyncSocket.alloc.initWithDelegate(self)
    @socket.connectToHost("0.0.0.0", onPort:"5001", error:nil)
    @socket.delegate  = self
  end

  def onSocketWillConnect(socket)
    p "WILL CONNECT!?"
  end

  def onSocket(socket, didConnectToHost: host, port: port)
    p "PDFKJLDSKFJKLSDJ"
    p "CONNECTED HOST: #{host}"
    p "CONNECTED PORT: #{port}"
  end

  def onSocket(socket, didWriteDataWithTag: tag)
    p "SENT"
    p "UNREAD DATA: #{socket.unreadData}"
  end

  def onSocket(socket, willDisconnectWithError: error)
    p "ERROR: #{error.localizedDescription}"
  end

  # def webSocketDidOpen(webSocket)
  #   puts "CONNECTED!"
  # end

  # def webSocket(webSocket, didFailWithError: error)
  #   puts "FAILED: #{error.localizedDescription}"
  #   @socket = nil
  # end

  # def webSocket(webSocket, didReceiveMessage: message)
  #   puts "RECEIVED: #{message}"
  # end

  # def webSocket(webSocket, didCloseWithCode: code, reason: reason, wasClean: wasClean)
  #   puts "CLOSING: #{code} #{reason} #{wasClean}"
  # end

  def load_picker
    turn_right_button("off")

    if @event[:affiliations].any? && !@event[:participating]
      self.view.addSubview(picker)
      picker.data   = event
      picker.parent = self
      picker.build_table
    elsif @event[:ended]
      self.view.addSubview(ended_notice)
      ended_notice.alert = @event[:ended_notice]
      ended_notice.notify
    else
      handle_pause
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

        if divider_number != @old_value
          reposition_bar(divider_number + 1)
          submit_feedback("#{array[divider_number][1]}", Time.now.to_i, Time.now.zone)
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

  def submit_feedback(value, timestamp, timezone)
    event_id = Pointer.new(:int)
    event_id.assign(@event["id"].to_i)

    user_id = Pointer.new(:int)
    user_id.assign(current_user_id.to_i)

    sent_value = Pointer.new(:int)
    sent_value.assign(value.to_i)

    affiliation = @event["current_participant"]["affiliation"].dataUsingEncoding(NSUTF8StringEncoding)

    packed_data = NSMutableData.alloc.initWithBytes(event_id, length: 4)
    packed_data.appendBytes(user_id, length: 4)
    packed_data.appendBytes(sent_value, length: 4)
    packed_data.appendData(affiliation)

    @socket.writeData(packed_data, withTimeout: -1, tag: 0)
  end

  def get_event
    data = { 'user[api_token]' => current_user_api_token }

    AFMotion::Client.shared.get("events/#{event[:id]}", data) do |result|
      if result.success?
        @event = result.object
        load_picker
      elsif result.failure?
        alert("Whoops", message: "#{result.object["errors"]}")
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
    bar_frame = CGRect.new([0, bar_position(6) - (divider_height / 2)], [self.view.frame.size.width, divider_height])
    @bar ||= DialBar.alloc.initWithOptions(bar_frame, self)
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

  def picker
    picker_frame = CGRect.new(
      [20, (self.view.bounds.size.height - 350) / 2],
      [self.view.frame.size.width - 40, 350]
    )
    @picker ||= PickerView.alloc.initWithFrame(picker_frame)
  end

  def ended_notice
    notice_frame = CGRect.new(
      [20, (self.view.bounds.size.height / 2) - 40],
      [self.view.frame.size.width - 40, 80]
    )
    @ended_notice ||= EndedNotice.alloc.initWithFrame(notice_frame)
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
      turn_right_button("on")
      paused_alert.removeFromSuperview
      start_updates
    else
      turn_right_button("off")
      stop_updates
      self.view.addSubview(paused_alert)
      paused_alert.addSubview(paused_label)
      paused_alert.addSubview(reminder_label)
    end
  end

  def paused_alert
    @paused_alert ||= UIView.alloc.initWithFrame(CGRectZero).tap do |pa|
      pa.frame              = CGRect.new(
        [20, (self.view.bounds.size.height / 2) - 65],
        [self.view.frame.size.width - 40, 130]
      )
      pa.backgroundColor    = UIColor.colorWithRed(50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 0.97)
      pa.layer.cornerRadius = 5.0
      pa.sizeToFit
    end
  end

  def paused_label
    @paused_label ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |pl|
      pl.frame = CGRect.new(
        [8, 8], [paused_alert.frame.size.width - 16, paused_alert.frame.size.height - 10]
      )
      pl.font          = UIFont.boldSystemFontOfSize(14)
      pl.numberOfLines = 0
      pl.lineBreakMode = UILineBreakModeWordWrap
      pl.color         = UIColor.whiteColor
      pl.text          = "Shake your phone to begin."
      pl.sizeToFit
      pl.textAlignment = UITextAlignmentCenter
      pl.center        = [(self.frame.size.width - pl.frame.size.width), 18]
    end
  end

  def reminder_label
    @reminder_label ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |pl|
      pl.frame = CGRect.new(
        [12, paused_label.frame.origin.y + paused_label.frame.size.height + 5],
        [paused_alert.frame.size.width - 24, paused_alert.frame.size.height - 10]
      )
      pl.font          = UIFont.systemFontOfSize(13)
      pl.numberOfLines = 0
      pl.lineBreakMode = UILineBreakModeWordWrap
      pl.color         = UIColor.whiteColor
      pl.text          = "Submit your feedback by tilting your phone or by dragging the dial. Tap the button in the top right at any time to change your preference."
      pl.sizeToFit
      pl.textAlignment = UITextAlignmentLeft
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
      alert("Device Error", "Tilt is unavailble. Please choose drag.")
    end
  end

  def stop_updates
    if @tilt_manager.isDeviceMotionAvailable
      @tilt_manager.stopDeviceMotionUpdates
    end
  end

  def paused_alert_showing?
    self.view.subviews.include?(paused_alert)
  end

  def frame
    @frame ||= self.view.frame
  end

  def manual_button
    @manual_button ||= UIBarButtonItem.alloc.initWithTitle("Drag", style: UIBarButtonItemStylePlain, target:self, action: 'switch_to_drag')
  end

  def tilt_button
    @tilt_button ||= UIBarButtonItem.alloc.initWithTitle("Tilt", style: UIBarButtonItemStylePlain, target:self, action: 'switch_to_tilt')
  end

  def switch_to_tilt
    @draggable = false
    determine_right_nav_button
    start_updates
  end

  def switch_to_drag
    @draggable = true
    determine_right_nav_button
    stop_updates
  end

  def determine_right_nav_button
    if @draggable
      self.navigationItem.rightBarButtonItem = tilt_button
    else
      self.navigationItem.rightBarButtonItem = manual_button
    end
  end

  def draggable?
    @draggable
  end

  def viewWillDisappear(animated)
    @socket.close

    stop_updates
  end

  def turn_right_button(switch)
    case switch
    when "on"
      self.navigationItem.rightBarButtonItem.enabled = true
    when "off"
      self.navigationItem.rightBarButtonItem.enabled = false
    end
  end

end