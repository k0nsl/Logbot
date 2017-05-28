# http://yahns.yhbt.net/yahns_config.txt
queue do
  worker_threads Integer(ENV['YAHNS_THREADS'] || 50)
end

app(:rack, 'config.ru', preload: true) do
  listen Integer(ENV['YAHNS_PORT'] || 15000)
  input_buffering true
  output_buffering true
  client_timeout 5
  persistent_connections true
end
