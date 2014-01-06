class NewEventController < Formotion::FormController

  attr_accessor :parent

  def init
    super.initWithForm(form)
  end

  def form
    @form ||= Formotion::Form.new({
      sections: [{
        rows: [{
          title: "Name",
          type: :string,
          key: :name
        }, {
          title: "Start Time",
          type: :date,
          picker_mode: :date_time,
          placeholder: "",
          key: :starts_at,
          format: :full,
          input_accessory: :done
        }, {
          title: "End Time",
          type: :date,
          picker_mode: :date_time,
          placeholder: "",
          key: :ends_at,
          format: :full,
          input_accessory: :done
        }]
      }, {
        rows: [{
          title: "Create This Event",
          type: :button
        }]
      }]
    })
  end

  def viewDidAppear(s)
    super

    self.title = "Create Event"

    cancel_button = UIBarButtonItem.alloc.initWithTitle("Cancel", style: UIBarButtonItemStyleBordered, target:self, action:'cancel')
    self.navigationItem.leftBarButtonItem = cancel_button

    create_button = UIBarButtonItem.alloc.initWithTitle("Create", style: UIBarButtonItemStyleBordered, target:self, action:'create')
    self.navigationItem.rightBarButtonItem = create_button

    create_button_two = form.sections[-1].rows[0]
    if create_button_two.title == "Create This Event"
      create_button_two.on_tap do |button|
        create()
      end
    end
  end

  def cancel
    self.dismissViewControllerAnimated(true, completion:lambda {})
  end

  def create
    data = {
      'event[name]'      => form.render[:name],
      'event[starts_at]' => form.render[:starts_at],
      'event[ends_at]'   => form.render[:ends_at],
      'user[api_token]'  => NSUserDefaults.standardUserDefaults["current_user"]["api_token"]
    }

    AFMotion::Client.shared.post("events", data) do |result|
      if result.success?
        parent.fetch_events("all")
        self.dismissViewControllerAnimated(true, completion:lambda {})
      else
      end
    end
  end

end