require_relative '../cutest_helper'
require 'cuba/tools/inflectors'

setup do
  {
    "widget_event" => "submit_note",
    "widget_name" => "claim_note",
    "claim_id" => "11242",
    "_method" => "post",
    "_csrf" => "AO6VtRx4gTbVvyppffF7ZF6P/tFG4aI+VnDcXXI7Ps0=",
    "claim_note" => {
      "claim_id" => "11242",
      "comment" => "",
      "permission" => "public",
      "recipient_ids" => ["2416"]
    }
  }
end

scope "inflectors" do
  test "#to_deep_ostruct" do |params|
    assert params.to_deep_ostruct.claim_note.recipient_ids.is_a? Array
  end
end
