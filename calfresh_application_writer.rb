require 'pdf_forms'

module Calfresh
  FORM_FIELDS = { name: 'Text1 PG 1', \
    home_address: 'Text4 PG 1', \
    home_city: 'Text5 PG 1', \
    home_state: 'Text6 PG 1', \
    home_zip_code: 'Text7 PG 1' \
  }

  class ApplicationWriter
    def initialize
      @pdftk = PdfForms.new('/usr/bin/pdftk')
    end

    def fill_out_form(field_input)
      validated_input = validate_form_input(field_input)
      input_for_pdf_writer = map_input_to_pdf_field_names(validated_input)
      @pdftk.fill_form './calfresh_application.pdf', \
        "/tmp/calfresh_application_filled_in_at_#{Time.now.strftime('%Y%m%d%H%M%S%L')}.pdf", \
        input_for_pdf_writer
    end

    #private
    def validate_form_input(form_input_hash)
      form_input_hash.select do |human_readable_field_name, value|
        FORM_FIELDS.has_key?(human_readable_field_name)
      end
    end

    def map_input_to_pdf_field_names(form_input)
      new_hash = Hash.new
      form_input.each do |human_readable_field_name, value|
        new_hash[FORM_FIELDS[human_readable_field_name]] = value
      end
      new_hash
    end
  end
end
