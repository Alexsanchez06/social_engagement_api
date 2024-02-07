namespace :airdrop do

  task :create => :environment do
    NAME = "AIRDROP EVENT"
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

  task :create_eagle_users => :environment do
    users = ['FrostyGem123','SwiftPanda456','QuantumByte78','CrimsonFox234','MysticJazz789','LunarWaves567','BlazeEcho321','StealthyFern876','PixelNebula234','CosmicDusk789','CelestialBolt','VelvetWhirl','EchoZephyr56','QuantumPulse','DaringLuna76','JazzMystic21','NebulaFrost88','SapphireHowl','EmberFlicker69','SolarRipple43','SereneCharm99','MidnightWisp','NimbusFury123','VelocityGlow','NovaCascade','ProwlWhisper','TwistedQuasar','StellarWink67','EnigmaBreeze','RadiantChase','CosmicChime44','QuantumQuill','VelvetSphinx','NebulaNova777','WhisperingSpectra','ShadowHarmony','VortexSparkle','EphemeralGlint','EtherealMingle','RadiantPulse22','LuminousLyric','QuantumGrove','StellarWisp88','EchoRipple67','SolarLullaby','SapphireSerenade','SwiftMystique','NebulaNectar','ThunderQuill','CelestialSpectra','DazzlingVortex','LunaLullaby33','ProwlMystique','QuantumEchoes','VelvetChime77','BlazeSphinx23','NebulaWhisperer','CosmicEmbrace','RadiantMingle','EtherealDusk88','LuminousVortex','ShadowSerenade','MysticQuill76','ThunderRipple33','CelestialWander','SwiftHarmony22','EmberCharm99','QuantumWaves56','SereneBreeze33','CrimsonSpectra','LunarQuasar44','VelvetWink22','RadiantNebula','QuantumProwl','WhisperingNova','BlazeRipple99','EtherealLuna','SolarLyric67','NimbusMystique','CosmicCascade','VelvetWhisperer','DaringQuasar','EtherealMingle99','SwiftSphinx22','BlazeWanderer','QuantumLullaby','LunaHarmony44','RadiantNebula99','NebulaQuill22','CelestialLyric','MysticCascade33','CosmicBreeze56','EmberGlint67','QuantumPulse22','LunarSerenade','NimbusRipple99','WhisperingCharm','ShadowWisp22','NovaQuill76','SapphireWaves']
    User.transaction do
      epoch = Epoch.live
      if epoch
        max = 300
        users.each do |username|
          user_name = User.find_by(username: username)
          unless user_name
            social_id = rand(10 ** 10)
            user = User.create(username: username, display_name: username.gsub(/\d/, '').gsub(/([A-Z])/, ' \1').strip, social_type: 'twitter-e', social_id: social_id)
            credits = rand((max-50)..max)
            Reward.find_or_create_by(user: user, epoch: Epoch.live, social_type: 'twitter-e', total_activity_points: credits, total_activity_count: credits / 30)
           puts "---User and reward created for user: #{user.username}---"
          end
        end
        epoch.aggregate_points
      end
    end
  end

  task :update_eagle_credits => :environment do
    Reward.transaction do
      epoch = Epoch.live
      if epoch
        rewards = Reward.where(social_type: 'twitter-e')
        rewards.each do |reward|
          credits = reward.total_activity_points.to_i + (reward.total_activity_points.to_i / 100) * 40
          reward.update_columns(total_activity_points: credits, total_activity_count: credits / 30) # increase the points 30%
        end
        epoch.aggregate_points
      end
    end
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
