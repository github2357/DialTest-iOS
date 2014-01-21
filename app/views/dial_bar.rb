class DialBar < UIView
  attr_accessor :parent

  def initWithOptions(frame, parent)
    initWithFrame(frame)

    self.backgroundColor = UIColor.clearColor

    self.addSubview(black_bar)

    self.parent = parent

    self
  end

  def touchesMoved(touches, withEvent:event)
    return unless draggable?
    add_arrows
    touch = touches.anyObject
    location = touch.locationInView(parent.view)
    if location.y < 64.0
      location.y = 64.0
    elsif location.y > (parent.frame.size.height - 40)
      location.y = parent.frame.size.height - 40
    end

    UIView.beginAnimations("Dragging A DraggableView", context:nil)
    self.frame = CGRectMake(self.frame.origin.x, location.y,
                            self.frame.size.width, self.frame.size.height)
    UIView.commitAnimations
  end

  def touchesEnded(touches, withEvent: event)
    remove_arrows
    touch = touches.anyObject
    location = touch.locationInView(parent.view)

    value = ((location.y - parent.height) / parent.divider_height).round
    parent.submit_feedback("#{parent.array[value][1]}", Time.now)
  end

  def draggable?
    parent.draggable?
  end

  def black_bar
    @black_bar ||= UIView.alloc.initWithFrame(CGRectZero).tap do |bb|
      bb.frame = CGRect.new(
        [0, (self.frame.size.height / 2) - 5],[self.frame.size.width, 10]
      )
      bb.backgroundColor = UIColor.blackColor
    end
  end

  def arrow_up
    @arrow_up ||= UIImageView.alloc.initWithImage(UIImage.imageNamed("arrow_up.png")).tap do |arrow|
      arrow.frame = CGRect.new(
        [(self.frame.size.width / 2) - 3.5, black_bar.frame.origin.y - 3],
        [7, 3.5]
      )
    end
  end

  def arrow_down
    @arrow_down ||= UIImageView.alloc.initWithImage(UIImage.imageNamed("arrow_down.png")).tap do |arrow|
      arrow.frame = CGRect.new(
        [(self.frame.size.width / 2) - 3.5, black_bar.frame.origin.y + black_bar.frame.size.height],
        [7, 3.5]
      )
    end
  end

  def add_arrows
    self.addSubview(arrow_up)
    self.addSubview(arrow_down)
  end

  def remove_arrows
    arrow_up.removeFromSuperview
    arrow_down.removeFromSuperview
  end

end