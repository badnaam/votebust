RAILS_ROOT=File.dirname(File.dirname(__FILE__))

God.watch do |w|
    script = " #{RAILS_ROOT}/script/delayed_job "
    env = "RAILS_ENV=production"
    w.name = 'delayed_job_production'
    w.group = 'voteable'
    w.interval = "1.minutes"
    w.start = "#{script} start #{env}"
    w.stop = "#{script} stop  #{env}"
    w.start = "#{script} restart  #{env}"
    w.start_grace = 30.seconds
    w.restart_grace = 30.seconds
    w.pid_file = "#{RAILS_ROOT}/tmp/delayed_job.pid"

    w.behavior(:clean_pid_file)

    w.start_if do |start|
        start.condition(:process_running) do |c|
            c.interval = 10.seconds
            c.running = false
        end
    end
    w.restart_if do |restart|
        restart.condition(:memory_usage) do |c|
            c.above = 80.megabytes
            c.times = [3, 5]
        end
        restart.condition(:cpu_usage) do |c|
            c.above = 20.percent
            c.times = 5
        end
    end

    w.lifecycle do |on|
        on.condition(:flapping) do |c|
            c.to_state = [:restart, :start]
            c.times = 5
            c.within = 5.minutes
            c.transition = :unmonitored
            c.retry_in = 10.minutes
            c.retry_times = 5
            c.retry_within = 2.hours
        end
    end
end