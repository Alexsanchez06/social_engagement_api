class Epoch < ApplicationRecord
  default_scope { where(alive: true).where("start_time <= ? and end_time >= ?", Time.now.utc, Time.now.utc) }
  scope :asc, -> { order("ID ASC") }
  scope :desc, -> { order("ID DESC") }

  has_many :users
  has_many :rewards
  has_many :claim_requests

  def self.live
    Epoch.last
  end

  def self.upcoming_epoch
    Epoch.unscoped.where("start_time > ?", Time.now.utc).asc.first
  end

  def self.previous_epoch
    Epoch.unscoped.where(alive: false).where("end_time < ?", Time.now.utc).desc.first    
  end

  def self.stats
    Epoch.live&.stats || raise('No epoch found')
  end

  def self.create_epoch(params)
    epoch_name = "OZONE AIRDROP EVENT"

    start_date = Time.parse(params[:start_date])
    end_date = Time.parse(params[:end_date])

    if start_date.to_time >= end_date
      raise 'Start Date should be lesser than End Date'
    end
    dhms = [60,60,24].reduce([(end_date - start_date.to_time)]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
    unless dhms.first <= 6
      raise "No. of days should be less than 6 days"
    end

    if Epoch.live
      raise "Already an Airdrop is live"
    end

    epoch = Epoch.create(name: epoch_name, start_time: start_date, end_time: end_date, alive: true)

    puts "--- Airdrop Created #{Epoch.unscoped.last.start_time} - #{Epoch.unscoped.last.end_time} ---"

    epoch
  end

  def self.delete_epoch(id)
    epoch = Epoch.unscoped.find_by_id(id)
    if epoch
      if epoch.rewards.blank? && SocialActivity.where(epoch_id: epoch.id).blank?
         epoch.delete
      else
         raise 'Airdrop Event Calculation Started'
      end
    end
  end

  def self.leader_board
    Reward.top(50).map do |reward|
      attrs = reward.user.attributes
      attrs["meta_data"] = nil
      reward.points.merge(attrs)
    end
  end

  def stats
    {
      total_points:, 
      total_mentions:, 
      start_time:, 
      end_time:, 
      alive:,
      total_participants:,
      print_status:
    }
  end

  def self.full_stats
    {
      previous_epoch: previous_epoch&.stats,
      current_epoch: Epoch.live&.stats,
      upcoming_epoch: upcoming_epoch&.stats
    }    
  end

  def aggregate_points
    total_points = 0
    total_mentions = 0
    self.rewards.pluck(:total_activity_points, :total_activity_count).each do |total|
      total_points += (total[0].to_i || 0)
      total_mentions += (total[1].to_i || 0)
    end

    self.total_points = total_points.to_s
    self.total_mentions = total_mentions.to_s
    self.save!
  end

  def print_status
    "#{name} [#{alive ? 'Alive' : 'Not Alive'}] - #{start_time} - #{end_time}"
  end

  def remaining_days
    [:dd, :hh, :mm, :ss].zip([60,60,24].reduce([(end_time - start_time)]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }).to_h
  end
end
