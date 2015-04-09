module DocumentProcessor
  extend self

  def combine_documents_into_single_pdf(file_array)
    pdf_file_array = file_array.map do |file|
      magick_object = MiniMagick::Image.open(file.path)
      if magick_object.type == 'PDF'
        file
      elsif ['JPG', 'JPEG', 'PNG', 'GIF'].include?(magick_object.type)
        pdf_path = "/tmp/#{random_string_for_temp_files}.pdf"
        prawn_pdf_doc = Prawn::Document.new
        prawn_pdf_doc.image(magick_object.path, fit: [500, 500])
        prawn_pdf_doc.render_file(pdf_path)
        pdf_doc = File.open(pdf_path)
        pdf_doc
      else
        nil
      end
    end.reject { |element| element == nil }
    pdf_paths = pdf_file_array.map { |file| file.path }
    path_for_docs_pdf = "/tmp/doc_set_#{random_string_for_temp_files}.pdf"
    system("convert #{pdf_paths.join(' ')} #{path_for_docs_pdf}")
    final_pdf = File.open(path_for_docs_pdf)
    final_pdf
  end

  def random_string_for_temp_files
    SecureRandom.hex + Time.now.strftime('%Y%m%d%H%M%S%L')
  end
end
