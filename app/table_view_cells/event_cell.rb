class EventCell < UITableViewCell
  include CurrentUser

  attr_accessor :event, :parent

  def init
    super

    self
  end

  def build
    self.contentView.addSubview(event_name)
    self.contentView.addSubview(event_details)
    self.contentView.addSubview(participant_count)

    if event[:participating]
      put_leave_button_on_top
    else
      put_join_button_on_top
    end
  end

  def event_name
    @event_name ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |en|
      en.font  = UIFont.boldSystemFontOfSize(15)
      en.frame = CGRect.new(
        [5, 5],
        [parent.view.frame.size.width, 20]
      )
      en.text  = "#{event[:name]}"
      en.sizeToFit
    end
  end

  def event_end_time
    @event_end_time ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |ee|
      ee.font  = UIFont.systemFontOfSize(12)
      ee.frame = CGRect.new(
        [5, event_starts_time.frame.origin.y + event_starts_time.frame.size.height + 2],
        [parent.view.frame.size.width, 20]
      )
      ee.text  = "#{event[:ends_at]}"
      ee.sizeToFit
    end
  end

  def event_starts_time
    @event_starts_time ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |es|
      es.font  = UIFont.systemFontOfSize(12)
      es.frame = CGRect.new(
        [5, event_name.frame.origin.y + event_name.frame.size.height + 2],
        [parent.view.frame.size.width, 20]
      )
      es.text  = "#{event[:starts_at]}"
      es.sizeToFit
    end
  end

  def event_details
    @event_details ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |es|
      es.font  = UIFont.systemFontOfSize(12)
      es.frame = CGRect.new(
        [5, event_name.frame.origin.y + event_name.frame.size.height + 2],
        [parent.view.frame.size.width, 20]
      )
      es.text  = "#{event[:details]}"
      es.sizeToFit
    end
  end

  def participant_count
    @participant_count ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |pc|
      pc.font  = UIFont.systemFontOfSize(12)
      pc.frame = CGRect.new(
        [parent.view.frame.size.width - (event_end_time.frame.origin.x + event_end_time.frame.size.width), event_end_time.frame.origin.y],
        [parent.view.frame.size.width, 20]
      )
      pc.text  = "#{event[:participant_count]}"
      pc.sizeToFit
    end
  end

  def join_button
    @join_button ||= UIButton.buttonWithType(UIButtonTypeCustom).tap do |button|
      button.backgroundColor = UIColor.whiteColor
      button.font            = UIFont.systemFontOfSize(11)
      button.setTitle("#{event[:join]}", forState:UIControlStateNormal)
      button.setTitleColor(UIColor.blueColor, forState:UIControlStateNormal)
      button.layer.borderWidth  = 1
      button.layer.borderColor  = UIColor.orangeColor.CGColor
      button.layer.cornerRadius = 2.0
      button.sizeToFit
      button.frame = [
        [parent.view.frame.size.width - 70, 7],
        [60, (self.contentView.frame.size.height - 14)]
      ]
      button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
      button.addTarget(self,
        action:"join",
        forControlEvents:UIControlEventTouchUpInside
      )
    end
  end

  def leave_button
    @leave_button ||= UIButton.buttonWithType(UIButtonTypeCustom).tap do |button|
      button.backgroundColor = UIColor.whiteColor
      button.font            = UIFont.systemFontOfSize(11)
      button.setTitle("#{event[:leave]}", forState:UIControlStateNormal)
      button.setTitleColor(UIColor.blueColor, forState:UIControlStateNormal)
      button.layer.borderWidth  = 1
      button.layer.borderColor  = UIColor.orangeColor.CGColor
      button.layer.cornerRadius = 2.0
      button.sizeToFit
      button.frame = [
        [parent.view.frame.size.width - 70, 7],
        [60, (self.contentView.frame.size.height - 14)]
      ]
      button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
      button.addTarget(self,
        action:"leave",
        forControlEvents:UIControlEventTouchUpInside
      )
    end
  end

  def join
    put_leave_button_on_top

    data = {
      'user[api_token]' => current_user_api_token,
      'id'              => event[:id]
    }

    AFMotion::Client.shared.post("event_participants", data) do |result|
      if result.success?
      else
        put_join_button_on_top
      end
    end
  end

  def leave
    put_join_button_on_top

    data = {
      'user[api_token]'    => current_user_api_token
    }

    AFMotion::Client.shared.delete("event_participants/#{event[:id]}", data) do |result|
      if result.success?
      else
        put_leave_button_on_top
      end
    end
  end

  def put_leave_button_on_top
    self.contentView.insertSubview(join_button, atIndex: 0)
    self.contentView.insertSubview(leave_button, atIndex: 1)
  end

  def put_join_button_on_top
    self.contentView.insertSubview(join_button, atIndex: 1)
    self.contentView.insertSubview(leave_button, atIndex: 0)
  end

end