require 'pdf_forms'

class CalfreshApplicationWriter
  def initialize
    @pdftk = PdfForms.new('/usr/bin/pdftk')
  end

  def fill_out_form(args)
    validated_field_values = args.select { |key| ['name','address'].include?(key.to_s) }
    # Need to replace keys with keys from form
    @pdftk.fill_form './calfresh_application.pdf', \
      "/tmp/calfresh_application_filled_in_at_#{Time.now.strftime('%Y%m%d%H%M%S%L')}.pdf", \
      validated_field_values
  end
end
