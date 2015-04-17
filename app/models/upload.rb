class Upload < ActiveRecord::Base
  #attr_accessible :upload
  has_attached_file :upload
  validates_attachment_content_type :upload, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "application/pdf"]

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      "delete_url" => upload_path(self),
      "delete_type" => "DELETE"
    }
  end

  def to_local_temp_file
    tf = Tempfile.new(SecureRandom.hex)
    tf.binmode
    upload.copy_to_local_file(:original, tf.path)
    tf.close
    tf
  end
end
