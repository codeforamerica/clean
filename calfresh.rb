require 'pdf_forms'
require 'securerandom'

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
    addlhh_4_ssn: "Text45 PG 3"
  }

  class ApplicationWriter
    def initialize
      @pdftk = PdfForms.new('pdftk')
    end

    def fill_out_form(input)
      base64_signature_blob = input[:signature]
      symbolized_key_input = symbolize_keys(input)
      symbolized_key_input_with_addlhhs = process_addl_hh_members(symbolized_key_input)
      validated_field_input = filter_input_for_valid_fields(symbolized_key_input_with_addlhhs)
      input_for_pdf_writer = map_input_to_pdf_field_names(validated_field_input)
      input_for_pdf_writer[FORM_FIELDS[:date]] = Date.today.strftime("%m/%d/%Y")
      input_for_pdf_writer['Check Box1 PG 3'] = "Yes"
      if symbolized_key_input[:medi_cal_interest] == "on"
        input_for_pdf_writer['Check Box24 PG 1'] = "Yes"
      end
      unique_key = SecureRandom.hex
      filled_in_form_path = "/tmp/application_#{unique_key}.pdf"
      @pdftk.fill_form('./calfresh_2pager.pdf', filled_in_form_path, input_for_pdf_writer)
      write_signature_png_to_tmp(base64_signature_blob, unique_key)
      convert_application_pdf_to_png_set(unique_key)
      add_signature_to_application(unique_key)
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

    def write_signature_png_to_tmp(signature_blob, unique_key)
      system("echo #{signature_blob} | base64 --decode > /tmp/signature_#{unique_key}.png")
    end

    def convert_application_pdf_to_png_set(unique_key)
      system("convert -alpha deactivate -density 300 -depth 8 -quality 85 /tmp/application_#{unique_key}.pdf /tmp/application_#{unique_key}.png")
    end

    def add_signature_to_application(unique_key)
      system("composite -geometry +31+2700 /tmp/signature_#{unique_key}.png /tmp/application_#{unique_key}-0.png /tmp/application_#{unique_key}-0.png")
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
      filename_array << "calfresh_application_images/page-7.png"
      filename_array << "/tmp/application_#{@unique_key}-1.png"
      (9..15).each do |page_number|
        filename_array << "calfresh_application_images/page-#{page_number}.png"
      end
      filename_array
    end

    def signed_png_path
      "/tmp/application_#{@unique_key}-0.png"
    end
  end

  class VerificationDoc
    attr_reader :original_file_path, :grayscaled_file_path, :sketched_file_path

    def initialize(doc_param)
      if doc_param.count > 0
        raw_doc = doc_param.first[1]
        raw_doc_path = raw_doc[:tempfile].path
        filename = raw_doc[:filename]
        new_file_path = raw_doc_path + filename
        new_file_path_no_spaces = new_file_path.gsub(" ", "")
        system("cp #{raw_doc_path} #{new_file_path_no_spaces}")
        @original_file_path = new_file_path_no_spaces
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
