# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Profitnext::Application.initialize!
   #Formatting DateTime to look like "20/01/2011 10:28PM"  
   Date::DATE_FORMATS[:default] = "%d-%m-%Y"  
   Time::DATE_FORMATS[:default] = "%d-%m-%Y %l:%M%p"  
