module Formotion
  module RowType
    class PickerWithDoneRow < PickerRow
      include RowType::ItemsMapper

      def after_build(cell)
        super
        keyboardDoneButtonView             = UIToolbar.new
        keyboardDoneButtonView.barStyle    = UIBarStyleBlack
        keyboardDoneButtonView.translucent = true
        keyboardDoneButtonView.tintColor   = nil
        keyboardDoneButtonView.sizeToFit

        doneButton = UIBarButtonItem.alloc.initWithTitle("Done", style:UIBarButtonItemStyleDone,  target:self, action: 'picker_done_clicked')
        spacer1    = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:self, action: nil)
        spacer     = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:self, action: nil)
        keyboardDoneButtonView.setItems([spacer, spacer1, doneButton])

        row.text_field.inputAccessoryView = keyboardDoneButtonView
      end

      def picker_done_clicked
        # just hide the keyboard...
        row.text_field.resignFirstResponder
      end
    end
  end
end