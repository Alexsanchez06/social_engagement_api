require 'csv'

class Reward < ApplicationRecord
  scope :by_epoch, ->(epoch_id){ where(epoch_id: epoch_id) }
  scope :by_user, ->(user_id){ where(user_id: user_id) }
  scope :having_points, ->{ where("total_activity_points != ?", "0") }

  belongs_to :user
  belongs_to :epoch

  def self.to_csv
    csv_data = CSV.generate(headers: true) do |csv|
      column_names = [:total_activity_count, :total_activity_points].map(&:to_s)
      csv << ['user_id', 'username'] + column_names
      epoch_id ||= Epoch.unscoped.last.id
      Reward.by_epoch(epoch_id).includes(:user).order("user_id ASC").each do |record|
        csv << ([record.user_id, record.user.username] + record.attributes.values_at(*column_names))
      end
    end
  end

  def self.top(n, epoch_id = nil)
    epoch_id ||= Epoch.unscoped.last.id

    Reward.by_epoch(epoch_id).having_points.includes(:user).order(Arel.sql("CAST(total_activity_points AS numeric) DESC")).limit(n)
  end

  def self.calculate_success_failure(epoch_id)
    epoch = Epoch.unscoped.find_by_id(epoch_id)
    rewards = Reward.by_epoch(epoch_id)
    end_of_day = rewards.pluck(:eod)

    success_count, fail_count = success_failure_calculation(end_of_day)
    epoch_dates = epoch_all_dates(epoch)

    final_result = epoch_dates.inject({}){|r, date| r[date] = {sucess: success_count[date], fail: fail_count[date]}; r;}
    {user_count: rewards.count, status: final_result }
  end

  def self.success_failure_calculation(end_of_day)
    success_count = Hash.new(0)
    fail_count = Hash.new(0)
    end_of_day.each do |eod|
      eod.each do |day_data|
        day_data.each do |date, result|
         if result == "success"
           success_count[date] += 1
         else
           fail_count[date] += 1
         end
        end
      end
    end
    [success_count, fail_count]
  end

  def self.epoch_all_dates(epoch)
    start_date = epoch.start_time.to_date
    end_date = epoch.end_time.to_date
    epoch_dates = (start_date..end_date).to_a.map(&:to_s)
    epoch_dates
  end

  def points
    {
      total_activity_points:,
      total_activity_count:,
      aggregated_points:,
      claim_status:,
      claim_address:,
      claimed_at:,
      claim_reference:
    }  
  end  
end
