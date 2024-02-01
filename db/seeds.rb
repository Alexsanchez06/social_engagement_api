# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Epoch
epoch = Epoch.create(name: 'Epoch 1', start_time: Time.now.utc, end_time: Time.now.utc + 6.days, alive: true)

# User
u1 = User.create(social_type: 'X', social_id: 119999720, username: 'forbethink', display_name: 'Manoj')
u2 = User.create(social_type: 'X', social_id: 170480994, username: 'manoj50848', display_name: 'Manoj 5080')

r1 = Reward.create(user: u1, epoch: epoch, social_type: 'X', total_activity_count: 1000, total_activity_points: 100000)
r2 = Reward.create(user: u1, epoch: epoch, social_type: 'X', total_activity_count: 2000, total_activity_points: 200000)

  app_config = AppConfig.create(twitter_client_id: 'YnZLS0dKRmNVREFWY2t2U04tMmU6MTpjaQ', twitter_client_secret: 'lHDxjTM1B1XrY0j_R7Gvz_TEU4Nsb6g1m1XzODUrPGVl0NqHXV', twitter_auth_token: 'AAAAAAAAAAAAAAAAAAAAAP1MqAEAAAAA3kmLd3QAkz%2BjU4TRYAAI96qmtl8%3D5yM8eCUGUmQkB5NbB1EnaBbNGSV3n2hb55yx9DZYBGjOBMXGLB', twitter_api_key: 'boBC8eT60G2EyOPXI0HIO671q', twitter_api_secret: 'kOeroC0LQWLnRk3HoqzRKYDCltKzy8L39IAGzdF5liQIYW8Ash', twitter_tags: '#ozonechain', admin_user: 'BabuVdineshbabu', is_enable_claim_notification: false, is_coming_soon: true,is_enable_login: true, is_enable_claim: false) if AppConfig.count.zero?