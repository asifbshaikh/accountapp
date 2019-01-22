namespace :db do
  task :backup do
     current_time = Time.now.to_datetime.to_formatted_s(:number)
     name_with_timestamp = current_time+'.sql'
     filename =  Rails.root.join('db').join('bak').join(name_with_timestamp)
     system "mysqldump -u root -padmin profitnext_development > #{filename}"
     system "tar --remove-files -czf #{filename}.tar.gz #{filename}"
     #system "rm #{filename}"
  end
end