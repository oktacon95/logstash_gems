# filter for c2 server out file (but the one with the naming context in the filename -- has date information included!)
require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::CPU_TEMP < LogStash::Filters::Base

  config_name "cpu_temp"

  # New plugins should start life at milestone 1.
  milestone 1

  def register
    # nothing to do
  end # def register

  def filter(event)
    # return nothing unless there's an actual filter event
    return unless filter?(event)
	
	originalmessage = event.get('message')
	
	# 12-10-2018 11:26:58 32.968
	# Trying to match the timestamp
	if /^([\d]{2}-[\d]{2}-[\d]{4}\s[\d]{2}:[\d]{2}:[\d]{2})\s([^*]+)$/.match(event.get('message'))
		
		begin
			rubytime = Time.strptime($1, "%d-%m-%Y %H:%M:%S")
			rubytime = rubytime - 7200
			logstash_time = LogStash::Timestamp.new(rubytime)
			event.set('@timestamp', logstash_time)
		rescue Exception => e  
			event.set('debuginfo', 'Failed to parse date <' + $1 + '>')
			@logger.warn('Failed to parse date <' + $1 + '>; message: ' + e.message + ', stacktrace:' + e.backtrace.inspect)
		end
		
		event.set('message', $2)
		# Trying to match the temperature
		if /^([\d]+\.[\d]+)$/.match(event.get('message'))
			event.set('temperature', $1.to_f)
		else
			event.set('debuginfo', "cannot read cpu temperature")
		end
	else
		event.set('debuginfo', "cannot read timestamp, bad format")
	end
	
	event.set('message', originalmessage)
	
    filter_matched(event)
	
  end # def filter
end # class LogStash::Filters::CPU_TEMP
