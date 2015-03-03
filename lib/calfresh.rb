module Calfresh
  FORM_FIELDS = { name: 'Text1 PG 1', \
    name_page3: 'Text3 PG 3', \
    home_address: 'Text4 PG 1', \
    home_city: 'Text5 PG 1', \
    home_state: 'Text6 PG 1', \
    home_zip_code: 'Text7 PG 1', \
    date: 'Text32 PG 1', \
    home_phone_number: 'Text12 PG 1', \
    email: 'Text13 PG 1', \
    date_of_birth: 'Text5 PG 3', \
    sex: 'Text6 PG 3', \
    ssn: 'Text3 PG 1', \
    ssn_page3: 'Text9 PG 3', \
    language_preference_reading: 'Text19 PG 1', \
    language_preference_writing: 'Text20 PG 1',
    addlhh_1_name: "Text12 PG 3",
    addlhh_1_date_of_birth: "Text14 PG 3",
    addlhh_1_sex: "Text15 PG 3",
    addlhh_1_ssn: "Text18 PG 3",
    addlhh_2_name: "Text21 PG 3",
    addlhh_2_date_of_birth: "Text23 PG 3",
    addlhh_2_sex: "Text24 PG 3",
    addlhh_2_ssn: "Text27 PG 3",
    addlhh_3_name: "Text30 PG 3",
    addlhh_3_date_of_birth: "Text32 PG 3",
    addlhh_3_sex: "Text33 PG 3",
    addlhh_3_ssn: "Text36 PG 3",
    addlhh_4_name: "Text39 PG 3",
    addlhh_4_date_of_birth: "Text41 PG 3",
    addlhh_4_sex: "Text42 PG 3",
    addlhh_4_ssn: "Text45 PG 3",
    interview_monday: 'Check Box47 PG 2',
    interview_tuesday: 'Check Box48 PG 2',
    interview_wednesday: 'Check Box49 PG 2',
    interview_thursday: 'Check Box50 PG 2',
    interview_friday: 'Check Box51 PG 2',
    interview_early_morning: 'Check Box52 PG 2',
    interview_mid_morning: 'Check Box53 PG 2',
    interview_afternoon: 'Check Box54 PG 2',
    interview_late_afternoon: 'Check Box55 PG 2'
  }

  class ApplicationWriter
    def initialize
      @pdftk = PdfForms.new('pdftk')
    end

    def fill_out_form(input)
      symbolized_key_input = symbolize_keys(input)
      symbolized_key_input_with_addlhhs = process_addl_hh_members(symbolized_key_input)
      validated_field_input = filter_input_for_valid_fields(symbolized_key_input_with_addlhhs)
      input_for_pdf_writer = map_input_to_pdf_field_names(validated_field_input)
      input_for_pdf_writer[FORM_FIELDS[:date]] = Time.zone.today.strftime("%m/%d/%Y")
      input_for_pdf_writer['Check Box1 PG 3'] = "Yes"
      if symbolized_key_input[:medi_cal_interest] == "on"
        input_for_pdf_writer['Check Box24 PG 1'] = "Yes"
      end
      unique_key = SecureRandom.hex
      
      # Fill in CF-285 to file: filled_in_form_path
      # TO DO: Add e-sig to CF-285
      filled_in_form_path = "/tmp/application_#{unique_key}.pdf"
      empty_form_path = File.expand_path("../calfresh/calfresh_3pager.pdf", __FILE__)
      @pdftk.fill_form(empty_form_path, filled_in_form_path, input_for_pdf_writer)

      # Add cover page to file: path_for_app_without_info_release_form
      path_for_app_without_info_release_form = "/tmp/final_application_without_info_release_#{unique_key}.pdf"
      cover_letter_path = File.expand_path("../calfresh/clean_cover_letter_v4.pdf", __FILE__)
      system("pdftk #{cover_letter_path} #{filled_in_form_path} cat output #{path_for_app_without_info_release_form}")

      # Add ROI form
      # TO DO: Add e-sig to ROI form
      path_for_info_release_form = "/tmp/info_release_form_#{unique_key}.pdf"
      info_release_form = InfoReleaseForm.new(client_information: validated_field_input, path_for_pdf: path_for_info_release_form)
      system("pdftk #{path_for_app_without_info_release_form} #{path_for_info_release_form} cat output /tmp/final_application_#{unique_key}.pdf")
      
      Application.new(unique_key)
    end

    def process_addl_hh_members(input)
      if input[:additional_household_members] != nil
        new_input = input
        input[:additional_household_members].each_with_index do |person_hash, array_index|
          index_starting_at_one = array_index + 1
          person_hash.each do |key, value|
            new_input["addlhh_#{index_starting_at_one}_#{key}".to_sym] = value
          end
        end
        return new_input
      else
        return input
      end
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

    def convert_application_pdf_to_png_set(unique_key)
      system("convert -alpha deactivate -density 300 -depth 8 -quality 85 /tmp/application_#{unique_key}.pdf /tmp/application_#{unique_key}.png")
    end

    def symbolize_keys(hash)
      symbolized_hash = Hash.new
      hash.each { |key,value| symbolized_hash[key.to_sym] = value }
      symbolized_hash
    end
  end

  class Application
    attr_reader :unique_key

    def initialize(unique_key)
      @unique_key = unique_key
      #write_pdf_from_pngs!
    end

    def final_pdf_path
      #"/tmp/final_application_pdf_#{unique_key}.pdf"
      "/tmp/final_application_#{unique_key}.pdf"
    end

    def has_pngs?
      files_exist = true
      png_filenames.each do |filename|
        if File.exists?(filename) == false
          files_exist = false
        end
      end
      files_exist
    end

    def png_file_set
      file_array = Array.new
      png_filenames.each do |filename|
        file_array << File.new(filename)
      end
      file_array
    end

    def png_filenames
      filename_array = Array.new
      filename_array << "/tmp/application_#{@unique_key}-0.png"
      filename_array << "/tmp/application_#{@unique_key}-1.png"
      filename_array << "/tmp/application_#{@unique_key}-2.png"
      path_to_image_folder = File.expand_path("../calfresh/calfresh_application_images", __FILE__)
      (9..15).each do |page_number|
        filename = path_to_image_folder + "/page-#{page_number}.png"
        filename_array << filename
      end
      filename_array
    end

    private
    def write_pdf_from_pngs!
      system("convert #{png_filenames.join(' ')} #{final_pdf_path}")
    end
  end

  class InfoReleaseForm
    def initialize(params)
      name = params[:client_information][:name]
      pdf = Prawn::Document.new
      pdf.font 'Helvetica'
      pdf.font('Helvetica', style: :bold) do
        pdf.text 'Subject: Authorization for release of information'
        pdf.text 'To: San Francisco Human Services Agency'
      end
      pdf.move_down 10
      pdf.text(<<EOF
I, #{name}, authorize you to release the following information regarding my CalFresh application or active case to Code for America:

- Case number
- Current and past application status
- Dates and reasons for all changes to the application status
- Current and past benefit allotment
- Reasons my case was pended or denied
- Description of all verification documents that were submitted

Code for America will use this information to make sure my case is processed properly.
EOF
)
      pdf.text(<<EOF
Name: #{name}
Date of birth: #{params[:client_information][:date_of_birth]}

Code for America
155 9th Street, San Francisco 94103
(415) 625-9633
www.codeforamerica.org
EOF
)
      pdf.render_file(params[:path_for_pdf])
    end
  end

  class VerificationDoc
    attr_reader :original_file_path, :grayscaled_file_path, :sketched_file_path

    def initialize(doc_param)
      if doc_param.count > 0
        raw_doc = doc_param.first[1]
        raw_doc_path = raw_doc.tempfile.path
        filename = raw_doc.original_filename
        new_file_path = raw_doc_path + filename
        new_file_path_no_special_chars = new_file_path.gsub(/[^a-zA-Z0-9_.]+/, "")
        system("cp #{raw_doc_path} #{new_file_path_no_special_chars}")
        @original_file_path = new_file_path_no_special_chars
      end
    end

    def pre_process!
      f = File.new(original_file_path)
      extension = File.extname(f)
      name_without_extension = File.basename(f, extension)
      directory_path = File.dirname(f)
      @grayscaled_file_path = directory_path + '/' + name_without_extension + "_grayscaled" + extension
      @sketched_file_path = directory_path + '/' + name_without_extension + "_sketched" + extension
      system("convert #{original_file_path} -geometry 1200x1200 -type Grayscale -brightness-contrast 25x25 #{grayscaled_file_path}")
      system("convert #{original_file_path} in.jpg -geometry 1200x1200 -brightness-contrast 25x25 -type Grayscale -bias 50% -morphology Convolve DoG:0x4 -negate -threshold 47% -gaussian-blur 1 #{sketched_file_path}")
    end

    def processed_file_set
      [File.new(grayscaled_file_path), File.new(sketched_file_path)]
    end
  end

  class VerificationDocSet
    attr_reader :filepaths_with_extensions

    def initialize(params)
      raw_docs = filter_hash_for_doc_keys(params)
      raw_doc_paths = raw_docs.map { |doc_name, doc_hash| doc_hash[:tempfile].path }
      @filepaths_with_extensions = raw_doc_paths.map do |raw_doc_path|
        file_call_result = `file -ib #{raw_doc_path}`
        extension = /\/(.+);/.match(file_call_result).captures.first
        new_file_path = raw_doc_path + "." + extension
        system("cp #{raw_doc_path} #{new_file_path}")
        new_file_path
      end
    end

    def file_array
      filepaths_with_extensions.map { |path| File.new(path) }
    end

    private
    def filter_hash_for_doc_keys(hash)
      hash.select do |key, value|
        ['identification', 'income', 'rent', 'utilities'].include?(key)
      end
    end
  end
end
