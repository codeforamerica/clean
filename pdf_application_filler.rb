### Experimenting to writing to PDF
### Currently:
### - Takes the CalFresh application and fills in each form with its (hidden) programmatic field name

require 'pdf_forms'

pdftk = PdfForms.new('/usr/bin/pdftk')
field_names = pdftk.get_field_names './calfresh_application.pdf'
field_name_hash = Hash.new
# Create a hash of field names where key == value
field_names.each do |field_name|
  field_name_hash[field_name] = field_name
end
# Fill out each form's field with the field name itself
pdftk.fill_form './form.pdf', "filled_in_form#{Time.now.strftime('%Y%m%d%H%M%S%L')}.pdf", field_name_hash
