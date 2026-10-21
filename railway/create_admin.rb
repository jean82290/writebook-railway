# Runs once, on the first boot of a Railway deployment (see entrypoint.sh).
# Does what Writebook's first-run page does, using the template's variables.

# Background jobs triggered here (image analysis for the bundled manual) run inline.
ActiveJob::Base.queue_adapter = :inline

if User.any?
  puts "[railway] Writebook already has an account: nothing to create."
else
  name = ENV["ADMIN_NAME"].to_s.strip
  user = FirstRun.create!(
    name: name.empty? ? "Admin" : name,
    email_address: ENV.fetch("ADMIN_EMAIL").strip,
    password: ENV.fetch("ADMIN_PASSWORD")
  )
  puts "[railway] Administrator created: #{user.email_address}."
  puts "[railway] Sign in with the ADMIN_PASSWORD value from this service's Variables tab."
end
