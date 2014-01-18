class SignUpController < Formotion::FormController

  def init
    super.initWithForm(form)
  end

  def form
    @form ||= Formotion::Form.new({
      sections: [{
        rows: [{
          title: "Email",
          type: :string,
          key: :email
        }]
      }, {
        rows: [{
          type: :picker,
          title: "Birthday",
          key: :Birthday,
          input_accessory: :done
        }]
      }, {
        rows: [{
          title: "Sign Up",
          type: :button
        }]
      }]
    })
  end

  def viewDidAppear(animated)
    super

    self.title = "Sign Up"

    cancel_button = UIBarButtonItem.alloc.initWithTitle("Cancel", style: UIBarButtonItemStyleBordered, target:self, action:'cancel')
    self.navigationItem.leftBarButtonItem = cancel_button

    signup_button = UIBarButtonItem.alloc.initWithTitle("Sign Up", style: UIBarButtonItemStyleBordered, target:self, action:'sign_up')
    self.navigationItem.rightBarButtonItem = signup_button

    signup_form_button = form.sections[-1].rows[0]
    if signup_form_button.title == "Sign Up"
      signup_form_button.on_tap do |button|
        sign_up()
      end
    end
  end

  def cancel
    self.dismissViewControllerAnimated(true, completion:lambda {})
  end

  def sign_up
    p "Sign up"
  end

end