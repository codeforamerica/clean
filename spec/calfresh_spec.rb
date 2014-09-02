require 'spec_helper'
require File.expand_path("../../calfresh", __FILE__)

describe Calfresh do
  it 'exists' do
    Calfresh
  end

  describe Calfresh::ApplicationWriter do
    let(:writer) { Calfresh::ApplicationWriter.new }
    let(:fake_pdftk) { double("PdfForms", :fill_form => "yay!") }
    let(:fake_date) { double("Date", :strftime => "08/28/2014" ) }

    before do
      allow(PdfForms).to receive(:new).and_return(fake_pdftk)
      allow(SecureRandom).to receive(:hex).and_return("fakehex")
      allow(Date).to receive(:today).and_return(fake_date)
      allow_any_instance_of(Calfresh::ApplicationWriter).to receive(:system)
    end

    describe '#fill_out_form' do
        let(:mandatory_pdf_form_inputs) { { "Text32 PG 1" => fake_date.strftime, "Check Box1 PG 3" => "Yes" } }

      context 'given 1 additional household member' do
        let(:fake_input) { {
          :additional_household_members => [ {
            name: "Joe Blow",
            date_of_birth: "12/23/85",
            sex: "M",
            ssn: "0001112222"
          }]
        } }

        it 'sends correct input' do
          desired_hash_subset = { "Text12 PG 3" => "Joe Blow", "Text14 PG 3" => "12/23/85", "Text15 PG 3" => "M", "Text18 PG 3" => "0001112222" }
          hash_for_fill_form = mandatory_pdf_form_inputs.merge(desired_hash_subset)
          expect(fake_pdftk).to receive(:fill_form).with("./calfresh_2pager.pdf", "/tmp/application_fakehex.pdf", hash_for_fill_form)
          writer.fill_out_form(fake_input)
        end
      end

      context 'given 4 (the max) additional household members' do
        let(:fake_input) { {
          :additional_household_members => [ {
            name: "Joe Blow",
            date_of_birth: "12/23/85",
            sex: "M",
            ssn: "0001112222"
          },
          {
            name: "name2",
            date_of_birth: "02/02/02",
            sex: "M",
            ssn: "2222222222"
          },
          {
            name: "name3",
            date_of_birth: "03/03/03",
            sex: "F",
            ssn: "3333333333"
          },
          {
            name: "name4",
            date_of_birth: "04/04/04",
            sex: "F",
            ssn: "4444444444"
          }
          ]
        } }

        it 'sends correct input' do
          desired_hash_subset = {
            "Text12 PG 3" => "Joe Blow",
            "Text14 PG 3" => "12/23/85",
            "Text15 PG 3" => "M",
            "Text18 PG 3" => "0001112222",
            "Text21 PG 3" => "name2",
            "Text23 PG 3" => "02/02/02",
            "Text24 PG 3" => "M",
            "Text27 PG 3" => "2222222222",
            "Text30 PG 3" => "name3",
            "Text32 PG 3" => "03/03/03",
            "Text33 PG 3" => "F",
            "Text36 PG 3" => "3333333333",
            "Text39 PG 3" => "name4",
            "Text41 PG 3" => "04/04/04",
            "Text42 PG 3" => "F",
            "Text45 PG 3" => "4444444444"
          }
          hash_for_fill_form = mandatory_pdf_form_inputs.merge(desired_hash_subset)
          expect(fake_pdftk).to receive(:fill_form).with("./calfresh_2pager.pdf", "/tmp/application_fakehex.pdf", hash_for_fill_form)
          writer.fill_out_form(fake_input)
        end
      end
    end
  end
end
