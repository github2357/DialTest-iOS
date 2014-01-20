class SignUpController < Formotion::FormController

  def init
    super.initWithForm(form)
  end

  def form
    @form ||= Formotion::Form.new({
      sections: [{
        title: "User Information",
        rows: [{
          title: "Email",
          auto_capitalization: :none,
          type: :string,
          key: :email
        }, {
          title: "Password",
          type: :string,
          secure: true,
          key: :password
        }]
      }, {
        title: "Profile Information",
        rows: [{
          type: :string,
          title: "Name",
          auto_capitalization: :words,
          key: :name,
          input_accessory: :done
        }, {
          title: "Birthday",
          type: :date,
          format: :medium,
          key: :birthday,
          input_accessory: :done
        }, {
          title: "Location",
          type: :string,
          auto_capitalization: :words,
          key: :location
        }, {
          title: "Gender",
          type: :picker,
          items: [
            ['Female', 'female'],['Male', 'male'],['Rather Not Say', 'rather not say']
          ],
          input_accessory: :done,
          key: :gender
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
    data = {
      'user[email]'             => form.render[:email],
      'user[password]'          => form.render[:password],
      'user[profile][name]'     => form.render[:name],
      'user[profile][birthday]' => birthday,
      'user[profile][location]' => form.render[:location],
      'user[profile][gender]'   => form.render[:gender]
    }

    AFMotion::Client.shared.post("users", data ) do |result|
      if result.success?
        NSUserDefaults.standardUserDefaults["current_user"] = result.object
        delegate = UIApplication.sharedApplication.delegate
        delegate.window.rootViewController = delegate.events_nav_controller
        SVProgressHUD.dismiss
      else
        SVProgressHUD.dismiss
        App.alert("Sign Up Failed", :message => result.object["errors"])
      end
    end
  end

  def birthday
    if form.render[:birthday].nil?
      nil
    else
      Time.at(form.render[:birthday])
    end
  end

end