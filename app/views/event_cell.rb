class EventCell < UITableViewCell
  attr_accessor :event, :parent

  def init
    super

    self
  end

  def build
    self.contentView.addSubview(event_name)
    self.contentView.addSubview(event_end_time)
    self.contentView.addSubview(event_starts_time)
    self.contentView.addSubview(participant_count)
    self.contentView.addSubview(action)
  end

  def event_name
    @event_name ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |en|
      en.font  = UIFont.systemFontOfSize(15)
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

  def action
    @action ||= UIButton.buttonWithType(UIButtonTypeCustom).tap do |button|
      button.backgroundColor = UIColor.whiteColor
      button.font            = UIFont.systemFontOfSize(11)
      button.setTitle("#{event[:action]}", forState:UIControlStateNormal)
      button.setTitleColor(UIColor.blueColor, forState:UIControlStateNormal)
      button.layer.borderWidth  = 1
      button.layer.borderColor  = UIColor.orangeColor.CGColor
      button.layer.cornerRadius = 2.0
      button.sizeToFit
      button.frame = [
        [parent.view.frame.size.width - 50, 3],
        [40, 30]
      ]
      button.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin
      button.addTarget(self,
        action:"event_action",
        forControlEvents:UIControlEventTouchUpInside
      )
    end
  end

  def event_action
    p "HOLY SHIT"
  end
end