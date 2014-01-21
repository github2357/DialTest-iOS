class SettingsCell < UITableViewCell
  attr_accessor :key, :value

  def init
    super

    cell.contentView.addSubview(label)
    cell.contentView.addSubview(content)

    self
  end

  def label
    @label ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |l|
      l.font  = UIFont.boldSystemFontOfSize(15)
      l.frame = CGRect.new(
        [10, 5],
        [70, 36]
      )
      l.text  = "#{key}"
    end
  end

  def content
    @content ||= UILabel.alloc.initWithFrame(CGRectZero).tap do |c|
      c.font  = UIFont.systemFontOfSize(15)
      c.frame = CGRect.new(
        [label.frame.origin.x + label.frame.size.width + 5, 5],
        [self.contentView.frame.size.width - 100, 36]
      )
      c.adjustsFontSizeToFitWidth = true
      c.textAlignment = UITextAlignmentRight
      c.text  = "#{value}"
    end
  end

end