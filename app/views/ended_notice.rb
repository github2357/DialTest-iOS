class EndedNotice < UIView
  attr_accessor :alert

  def initWithFrame(frame)
    super

    self.frame              = frame
    self.backgroundColor    = UIColor.colorWithRed(50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 0.95)
    self.layer.cornerRadius = 5.0
    self.sizeToFit

    self
  end

  def alert=(alert)
    @alert = alert
  end

  def notify
    self.addSubview(notice)
  end

  def notice
    @notice ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |n|
      n.frame         = CGRect.new(
        [15, 10],
        [self.frame.size.width - 30, self.frame.size.height]
      )
      n.font          = UIFont.systemFontOfSize(15)
      n.text          = "#{alert}"
      n.color         = UIColor.whiteColor
      n.lineBreakMode = UILineBreakModeWordWrap
      n.numberOfLines = 0
      n.sizeToFit
      n.center        = [self.frame.size.width / 2, self.frame.size.height / 2]
    end
  end

end