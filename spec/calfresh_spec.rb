require 'spec_helper'
require File.expand_path("../../calfresh", __FILE__)

describe Calfresh do
  it "exists" do
    Calfresh
  end

=begin
  describe Calfresh::ApplicationWriter do
    let(:application_writer) { Calfresh::ApplicationWriter.new }

    it 'fills out a form' do
      application_writer.fill_out_form({key: "value"})
    end
  end
=end
end
