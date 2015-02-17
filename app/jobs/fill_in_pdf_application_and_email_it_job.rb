class FillInPdfApplicationAndEmailItJob < ActiveJob::Base
  queue_as :default

  def perform(input_for_writer)
    writer = Calfresh::ApplicationWriter.new
    application = writer.fill_out_form(input_for_writer)
    client = SendGrid::Client.new(api_user: ENV['SENDGRID_USERNAME'], api_key: ENV['SENDGRID_PASSWORD'])
    mail = SendGrid::Mail.new(
      to: ENV['EMAIL_ADDRESS_TO_SEND_TO'],
      from: 'suzanne@cleanassist.org',
      subject: 'New Clean CalFresh Application!',
      text: <<EOF
Hi there!

An application for Calfresh benefits was just submitted!

You can find a completed CF-285 in the attached .zip file. You will probably receive another e-mail shortly containing photos of their verification documents.

The .zip file attached is encrypted because it contains sensitive personal information. If you don't have a password to access it, please get in touch with Jake Solomon at jacob@codeforamerica.org

When you finish clearing the case, please help us track the case by filling out a bit of info here: http://c4a.me/cleancases

Thanks for your time!

Suzanne, your friendly neighborhood CalFresh robot
EOF
    )
    random_value = SecureRandom.hex
    zip_file_path = "/tmp/#{random_value}.zip"
    Zip::Archive.open(zip_file_path, Zip::CREATE) do |ar|
      ar.add_file(application.final_pdf_path) # add file to zip archive
    end
    Zip::Archive.encrypt(zip_file_path, ENV['ZIP_FILE_PASSWORD'])
    puts zip_file_path
    mail.add_attachment(zip_file_path)
    #email_result_application = client.send(mail)
    email_result_application = "job would have produced this"
    puts email_result_application
    puts "Hey! The job was run at: #{Time.now.to_s}"
  end
end
