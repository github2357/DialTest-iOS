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

end