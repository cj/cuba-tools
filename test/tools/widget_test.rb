require_relative '../cutest_helper'
require "slim"
require "cuba/render"

setup do
  Cuba.reset!
  Cuba::Tools::Widget.reset_config!
  Cuba::Tools::Widget.setup do |c|
    c.widgets = {
      some_widget: 'SomeWidget',
      other_widget: 'OtherWidget'
    }
    c.view_path = Dir.pwd + '/test/dummy/app/widgets'
  end
  Cuba.use Cuba::Tools::Widget::Middleware
  Cuba.plugin Cuba::Tools::Widget::Helpers
  Cuba.plugin Cuba::Render
  Cuba.settings[:render][:options] ||= {
    default_encoding: Encoding.default_external
  }
  Cuba.define do
    def test_helper
      'test_helper'
    end

    on "test" do
      res.write render_widget :some_widget
    end

    on root do
      res.write 'default'
    end
  end
end

scope "tools/widget" do
  test "config" do
    assert Cuba::Tools::Widget.config.url_path == '/widgets'
    Cuba::Tools::Widget.setup do |config|
      config.url_path = '/new'
    end
    assert Cuba::Tools::Widget.config.url_path == '/new'
  end
end

scope "cuba/tools/widget/middleware" do
  test 'default' do
    status, headers, resp = Cuba.call({
      'PATH_INFO' => '/widgets',
      'rack.input'     => {}
    })
    body = resp.send('body').join

    assert status == 200
    assert headers['Content-Type'] == "text/javascript; charset=utf-8"
    assert body[/\$\(document\)/] != nil
    assert body[/default/] == nil

    _, _, resp = Cuba.call({
      'PATH_INFO' => '/',
      'rack.input'     => {}
    })
    body = resp.send('body').join

    assert body[/\$\(document\)/] == nil
    assert body[/default/] != nil
  end

  test 'widget events' do
    _, _, resp = Cuba.call({
      'PATH_INFO'   => '/widgets',
      'REQUEST_METHOD' => 'GET',
      'rack.input'     => {},
      'QUERY_STRING'   => 'widget_name=some_widget&widget_event=test'
    })
    body = resp.send('body').join

    assert body[/moo/] != nil
    assert body[/cow/] != nil
  end

  test '#render_widget' do
    _, _, resp = Cuba.call({
      'PATH_INFO'   => '/test',
      'SCRIPT_NAME'   => '/test',
      'REQUEST_METHOD' => 'GET',
      'rack.input'     => {}
    })
    body = resp.send('body').join

    assert body['test_helper'] != nil
    assert body['display'] != nil
    assert body['id="some_widget_display"'] != nil
    assert body['some partial'] != nil
    assert body['some state'] != nil
    assert body['user_widget_method'] != nil
    assert body['id="some_widget_some_state"'] != nil
  end
end
