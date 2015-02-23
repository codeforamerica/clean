require 'spec_helper'
require File.expand_path("../../../lib/calfresh", __FILE__)

describe Calfresh do
  it 'exists' do
    Calfresh
  end

  describe Calfresh::ApplicationWriter do
    let(:writer) { Calfresh::ApplicationWriter.new }
    let(:fake_pdftk) { double("PdfForms", :fill_form => "yay!") }
    let(:fake_date) { double("Date", :strftime => "08/28/2014" ) }
    let(:fake_prawn_document) { double("Prawn::Document", :text => true, :image => true, :render_file => true, :font => true, :move_down => true) }

    before do
      allow(PdfForms).to receive(:new).and_return(fake_pdftk)
      allow(SecureRandom).to receive(:hex).and_return("fakehex")
      allow(Date).to receive(:today).and_return(fake_date)
      allow_any_instance_of(Calfresh::ApplicationWriter).to receive(:system)
      allow(Kernel).to receive(:system)
      allow(Prawn::Document).to receive(:new).and_return(fake_prawn_document)
    end

    describe '#fill_out_form' do
      let(:mandatory_pdf_form_inputs) { { "Text32 PG 1" => fake_date.strftime, "Check Box1 PG 3" => "Yes" } }
      let(:path_for_3_pager_pdf) { File.expand_path("../../../lib/calfresh/calfresh_3pager.pdf", __FILE__) }

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
          expect(fake_pdftk).to receive(:fill_form).with(path_for_3_pager_pdf, "/tmp/application_fakehex.pdf", hash_for_fill_form)
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
          expect(fake_pdftk).to receive(:fill_form).with(path_for_3_pager_pdf, "/tmp/application_fakehex.pdf", hash_for_fill_form)
          writer.fill_out_form(fake_input)
        end
      end

      context 'given all interview times selected' do
        let(:fake_input) { {
          interview_early_morning: 'Yes',
          interview_mid_morning: 'Yes',
          interview_afternoon: 'Yes',
          interview_late_afternoon: 'Yes',
          interview_monday: 'Yes',
          interview_tuesday: 'Yes',
          interview_wednesday: 'Yes',
          interview_thursday: 'Yes',
          interview_friday: 'Yes'
          }
        }

        it 'checks all the selected interview time boxes available via app' do
          desired_hash_subset = Hash.new
          (47..55).each do |number|
            desired_hash_subset["Check Box#{number} PG 2"] = 'Yes'
          end
          hash_for_fill_form = mandatory_pdf_form_inputs.merge(desired_hash_subset)
          expect(fake_pdftk).to receive(:fill_form).with(path_for_3_pager_pdf, "/tmp/application_fakehex.pdf", hash_for_fill_form)
          writer.fill_out_form(fake_input)
        end
      end

      describe 'system calls' do
        let(:fake_input) {
          {
            signature: 'fakesignatureblob'
          }
        }

        before do
          writer.fill_out_form(fake_input)
        end

        it 'converts the base 64 signature' do
          command = "echo fakesignatureblob | base64 --decode > /tmp/signature_fakehex.png"
          expect(writer).to have_received(:system).with(command)
        end

        it 'scales the signature with imagemagick' do
          command = "convert /tmp/signature_fakehex.png -background none -gravity southwest -extent 2500x2400 /tmp/signature_scaled_fakehex.png"
          expect(writer).to have_received(:system).with(command)
        end

        it 'converts the scaled signature from png to pdf' do
          command = "convert /tmp/signature_scaled_fakehex.png /tmp/sig_pdf_fakehex.pdf"
          expect(writer).to have_received(:system).with(command)
        end

        it 'stamps the application with the signature pdf' do
          command = "pdftk /tmp/application_fakehex.pdf stamp /tmp/sig_pdf_fakehex.pdf output /tmp/final_application_no_cover_letter_fakehex.pdf"
          expect(writer).to have_received(:system).with(command)
        end

        it 'adds the cover letter to the application PDF' do
          cover_letter_path_from_spec = File.expand_path("../../../lib/calfresh/clean_cover_letter_v3.pdf", __FILE__)
          command = "pdftk #{cover_letter_path_from_spec} /tmp/final_application_no_cover_letter_fakehex.pdf cat output /tmp/final_application_fakehex.pdf"
          expect(writer).to have_received(:system).with(command)
        end
      end

      describe 'creation of info release form' do
        let(:test_input) {
          {
            name: 'John Reis',
            date_of_birth: '01/02/53'
          }
        }

        before do
          writer.fill_out_form(test_input)
        end

        it 'sends correct core body input to the Prawn document' do
          expect(fake_prawn_document).to have_received(:text).with(<<EOF
I, #{test_input[:name]}, authorize you to release the following information regarding my CalFresh application or active case to Code for America:

- Case number
- Current and past application status
- Dates and reasons for all changes to the application status
- Current and past benefit allotment
- Reasons my case was pended or denied
- Description of all verification documents that were submitted

Code for America will use this information to make sure my case is processed properly.
EOF
)
          expect(fake_prawn_document).to have_received(:text).with(<<EOF
Name: #{test_input[:name]}
Date of birth: #{test_input[:date_of_birth]}

Code for America
155 9th Street, San Francisco 94103
(415) 625-9633
www.codeforamerica.org
EOF
)
        end

        it 'draws the signature image resized to 30%' do
          expect(fake_prawn_document).to have_received(:image).with('/tmp/signature_fakehex.png', scale: 0.3)
        end

        it 'writes the info release form to the correct path' do
          expect(fake_prawn_document).to have_received(:render_file).with("/tmp/info_release_form_fakehex.pdf")
        end

        it 'sets the font to Helvetica' do
          expect(fake_prawn_document).to have_received(:font).with('Helvetica')
        end

        it 'adds the info release pdf to the final application' do
          # TODO - properly mock the system call here

          expect(Kernel).to have_received(:system).with("pdftk /tmp/final_application_without_info_release_fakehex.pdf /tmp/info_release_form_fakehex.pdf cat output /tmp/final_application_fakehex.pdf")
        end
      end
    end
    # TODO — write test for nil input for date of birth
  end
end
