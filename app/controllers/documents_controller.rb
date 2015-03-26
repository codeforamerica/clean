class DocumentsController < ApplicationController
  def new
    @token = params[:user_token]
    @number_of_docs = params[:number_of_docs]
  end

  def new_ajax
    render json: {}
  end

  def new_v2
    render :new_v2, layout: false
  end

  def new_from_example
  end

  def create
    puts params.to_hash
    token = params[:user_token]
    doc_number = params[:doc_number].to_i
    redis = Redis.new(:url => URI.parse(ENV['REDISTOGO_URL']))
    doc = Calfresh::VerificationDoc.new(params)
    image_binary = IO.binread(doc.original_file_path)
    key_base = "#{token}_#{doc_number}"
    redis.set(key_base + "_binary", image_binary)
    redis.expire(key_base + "_binary", redis_expiration_time)
    new_number_of_docs = doc_number + 1
    redirect_to "/documents/#{params[:user_token]}/#{new_number_of_docs}"
  end

  def submit
    token = params[:user_token]
    max_doc_index = params[:doc_number].to_i - 1
    redis = Redis.new(:url => URI.parse(ENV['REDISTOGO_URL']))
    file_paths_array = Array.new
    (0..max_doc_index).to_a.each do |index|
      # Get binary from Redis
      binary = redis.get("#{token}_#{index}_binary")
      temp_file_name = SecureRandom.hex
      temp_file_path = "/tmp/" + temp_file_name
      File.open(temp_file_path, 'wb') do |file|
        file.write(binary)
      end
      # Add full path for new file to array
      file_paths_array << temp_file_path
      # Delete Redis data
      redis.del("#{token}_#{index}_binary")
    end
    # Combine all files into single PDF
    final_pdf_path = "/tmp/#{token}_all_images.pdf"
    convert_command = "convert #{file_paths_array.join(' ')} #{final_pdf_path}"
    Kernel.system(convert_command)
    # Encrypt and zip file
    zip_file_path = "/tmp/#{token}_zipped.zip"
    Zip::Archive.open(zip_file_path, Zip::CREATE) do |ar|
      ar.add_file(final_pdf_path) # add file to zip archive
    end
    Zip::Archive.encrypt(zip_file_path, ENV['ZIP_FILE_PASSWORD'])
    # Email file
    sendgrid_client = SendGrid::Client.new(api_user: ENV['SENDGRID_USERNAME'], api_key: ENV['SENDGRID_PASSWORD'])
    mail = SendGrid::Mail.new(
      to: ENV['EMAIL_ADDRESS_TO_SEND_TO'],
      from: 'suzanne@cleanassist.org',
      subject: 'New Clean CalFresh Verification Docs!',
      text: <<EOF
Hi there!

Verification docs were just submitted for a CalFresh application!

You can find the docs in the attached .zip file.

The .zip file attached is encrypted because it contains sensitive personal information. If you don't have a key to access it, please get in touch with Jake Soloman at jacob@codeforamerica.org

Thanks for your time!

Suzanne, your friendly neighborhood CalFresh robot
EOF
    )
    mail.add_attachment(zip_file_path)
    @email_result_application = sendgrid_client.send(mail)
    puts @email_result_application
    redirect_to "/complete"
  end

  private
  def redis_expiration_time
    3600
  end
end
