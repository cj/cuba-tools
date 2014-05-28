require 'cuba/tools'

class OtherWidget < Cuba::Tools::Widget::Base
  respond_to :test, for: :some_widget, with: :some_test

  def some_test
    res.write 'cow'
  end
end
