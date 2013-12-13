class SlideController < UIViewController
  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.whiteColor
    self.title = "WHAT"

    self.view.addSubview(slide)
  end

  def slidetastic
    data = {
      'response[event_id]' => 1,
      'response[user_id]'  => 3,
      'response[value]'    => slide.value.ceil,
      'user[api_token]'    => "1cfc0f51520db5a3f5dfebb8bd437618"
    }
    AFMotion::Client.shared.post("events/1/responses", data) do |result|
      parsed_string = result.object
      if result.success?
        p parsed_string
      end
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
end