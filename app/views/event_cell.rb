class EventCell < UITableViewCell
  attr_accessor :event, :parent

  def init
    super

    self
  end

  def build
    # self.contentView.addSubview(event_name)
    # self.contentView.addSubview(event_end_time)
    # self.contentView.addSubview(participant_count)
    # self.contentView.addSubview(action)
  end

  def event_name
    @event_name ||= event[:name]
  end

  def event_end_time
    @event_end_time ||= event[:ends_at]
  end

  def participant_count
    @participant_count ||= "3"
  end

  def action
    @action ||= "HI"
  end
end