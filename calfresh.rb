require 'pdf_forms'
require 'securerandom'

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

    def fill_out_form(input)
      base64_signature_blob = input[:signature]
      validated_field_input = filter_input_for_valid_fields(input)
      input_for_pdf_writer = map_input_to_pdf_field_names(validated_field_input)
      unique_key = SecureRandom.hex
      filled_in_form_path = "/tmp/application_#{unique_key}.pdf"
      @pdftk.fill_form('./calfresh_application.pdf', filled_in_form_path, input_for_pdf_writer)
      write_signature_png_to_tmp(base64_signature_blob, unique_key)
      convert_application_pdf_to_png_set(unique_key)
      add_signature_to_application(unique_key)
    end

    #private
    def filter_input_for_valid_fields(form_input_hash)
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

    def write_signature_png_to_tmp(signature_blob, unique_key)
      system("echo #{signature_blob} | base64 --decode > /tmp/signature_#{unique_key}.png")
    end

    def convert_application_pdf_to_png_set(unique_key)
      system("convert -alpha deactivate -density 300 -depth 8 -quality 85 /tmp/application_#{unique_key}.pdf /tmp/application_#{unique_key}.png")
    end

    def add_signature_to_application(unique_key)
      system("composite -geometry +31+2700 /tmp/signature_#{unique_key} application_#{unique_key}-6.png application_#{unique_key}-6-signed.png")
    end
  end
end
