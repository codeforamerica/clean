class Case < ActiveRecord::Base

  def self.process_data_for_storage(input_hash)
    data_to_save = input_hash.select do |k,v|
      %w(name date_of_birth home_phone_number email home_address home_zip_code home_city home_state primary_language sex additional_household_members contact_by_email contact_by_text_message contact_by_phone_call interview_early_morning interview_mid_morning interview_afternoon interview_late_afternoon interview_monday interview_tuesday interview_wednesday interview_thursday interview_friday).include?(k)
    end
    data_to_save['date_of_birth'] = Chronic.parse(data_to_save['date_of_birth'])
    if data_to_save['additional_household_members']
      household_members_data_without_ssn = data_to_save['additional_household_members'].map do |hhm|
        hhm.select do |k,v|
          k.to_s != 'ssn'
        end
      end
      data_to_save['additional_household_members'] = household_members_data_without_ssn
    end
    data_to_save.each do |k,v|
      if k.include?('interview') && data_to_save[k] == 'Yes'
        data_to_save[k] = true
      end
    end
    data_to_save
  end

end
