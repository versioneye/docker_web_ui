#!/bin/bash

### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
BUNDLE=/usr/local/bin/bundle
UNICORN=/usr/local/bin/unicorn_rails
KILL=/bin/kill
APP_ROOT=/var/www/docker_web_ui/current
PID=$APP_ROOT/pids/unicorn.pid
OLD_PID=$APP_ROOT/pids/unicorn.pid.oldbin
CONF=$APP_ROOT/unicorn.conf.rb
GEM_HOME=/var/www/docker_web_ui/shared/bundle/ruby/2.1.0/gems/

export REMOTE_IMAGES=""
export DOCKER_USER='' 
export DOCKER_PASSWORD=''
export DOCKER_EMAIL=''


sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

case "$1" in
        start)
                echo "Starting unicorn rails app ..."
                cd $APP_ROOT
                $BUNDLE exec unicorn_rails -D -c $CONF
                echo "Unicorn rails app started!"
                ;;
        stop)
                echo "Stoping unicorn rails app ..."
                sig QUIT && exit 0
                echo "Not running"
                ;;
        restart)
                if [ -f $PID ];
                then
                   echo "Unicorn PID $PID exists"
                   sig QUIT
                   sleep 5
                   $0 start
                else
                   echo "Unicorn rails app is not running. Lets start it up!"
                   $0 start
                fi
                ;;
        status)
                ;;
        *)
                echo "Usage: $0 {start|stop|restart|status}"
                ;;
esac
