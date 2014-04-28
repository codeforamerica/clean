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

    def fill_out_form(args)
      validated_field_values = args.select { |key| ['name','address'].include?(key.to_s) }
      # Need to replace keys with keys from form, accessible via Calfresh::FORM_FIELDS
      @pdftk.fill_form './calfresh_application.pdf', \
        "/tmp/calfresh_application_filled_in_at_#{Time.now.strftime('%Y%m%d%H%M%S%L')}.pdf", \
        validated_field_values
    end
  end
end
