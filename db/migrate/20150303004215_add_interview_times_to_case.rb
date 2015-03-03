class AddInterviewTimesToCase < ActiveRecord::Migration
  def change
    add_column :cases, :interview_early_morning, :boolean
    add_column :cases, :interview_mid_morning, :boolean
    add_column :cases, :interview_afternoon, :boolean
    add_column :cases, :interview_late_afternoon, :boolean
    add_column :cases, :interview_monday, :boolean
    add_column :cases, :interview_tuesday, :boolean
    add_column :cases, :interview_wednesday, :boolean
    add_column :cases, :interview_thursday, :boolean
    add_column :cases, :interview_friday, :boolean
  end
end
