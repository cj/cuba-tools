class SomeWidget < Cuba::Tools::Widget::Base
  respond_to :test

  def display
    set_state :some_state

    render
  end

  def some_state
    render
  end

  def test
    res.write 'moo'
  end

  def user_widget_method
    'user_widget_method'
  end
end
