namespace :airdrop do

  task :create => :environment do
    NAME = "OZONE AIRDROP EVENT"
    START_DATE = '16-12-2023 15:20:00'
    END_DATE = '16-12-2023 15:40:00'
    DAYS = 6

    start_date = Time.parse(START_DATE)
    # end_date = start_date + DAYS.days - 1.second    
    end_date = Time.parse(END_DATE)

    if start_date.to_time >= end_date
      raise '***** Error: Start Date should be lesser than End Date *****'
    end
    dhms = [60,60,24].reduce([(end_date - start_date.to_time)]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
    unless dhms.first <= 6
      raise "***** Error: No. of days should be less than 6 days  *****"
    end

    if Epoch.live
      raise "***** Error: Already an Airdrop is live. To force stop: `rails airdrop:end_alive` *****"
    end

    Epoch.create(name: NAME, start_time: start_date, end_time: end_date, alive: true)

    puts "--- Airdrop Created #{Epoch.unscoped.last.start_time} - #{Epoch.unscoped.last.end_time} ---"
  end

  task :create_upcoming => :environment do
    NAME = "AIRDROP"
    START_DATE = '11-10-2023'
    END_DATE = '15-10-2023'

    start_date = Date.parse(START_DATE)
    end_date = Date.parse(END_DATE)

    if start_date >= end_date
      raise '***** Error: Start Date should be lesser than End Date *****'
    end

    unless (end_date - start_date).days < 6.days
      raise "***** Error: No. of days should be less than 6 days  *****"
    end

    if Time.now.utc > start_date 
      raise '***** Error: Start Date should be greater than today *****'
    end

    if Epoch.upcoming_epoch.present?
      raise "***** Error: Already an UPCOMING AIRDROP added. *****"
    end

    Epoch.create(name: NAME, start_time: start_date, end_time: end_date, alive: false)

    puts "--- NEXT AIRDROP Created #{start_date} - #{end_date} ---"
  end

  task :live_upcoming => :environment do

    if Epoch.live.present?
      Epoch.live.update_columns(alive: false)
    end

    if Epoch.upcoming_epoch.blank?
      raise "***** Error: NEXT AIRDROP shouldn't be blank. try `rails airdrop:create_next_airdrop` *****"
    end

    Epoch.upcoming_epoch.update_columns(alive: true)

    puts "--- NEXT AIRDROP is live now #{Epoch.live.start_time} - #{Epoch.live.end_time} ---"
  end  

  task :status => :environment do
    pp Epoch.full_stats
  end

  task :end_alive => :environment do
    unless Epoch.unscoped.live
      raise "***** Error: No airdrop alive now *****"
    end

    Epoch.live.update_columns(alive: false)

    puts "--- Airdrop ended ---"
  end

  task :sync_eod => :environment do
    puts "Twitter sync Started."
    TwitterSyncJob.perform_now(eod: true)
    puts "Twitter sync Completed."
  end

  task :sync_realtime => :environment do
    puts "Twitter sync Started."
    TwitterSyncJob.perform_now(eod: false)
    puts "Twitter sync Completed."
  end
end
