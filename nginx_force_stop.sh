kill -9 $(ps -ax | grep 'nginx: master process' | sed -n '1p' | tr -s ' ' | cut -d ' ' -f 1)
killall 'nginx: worker process'
killall 'nginx: worker process is shutting down'
