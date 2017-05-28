# encoding: utf-8
Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

require "json"
require "time"
require "date"
require "erb"
require "cgi"

require "redis"
require "jellyfish"

# ruby 1.9- compatibility
unless respond_to?(:__dir__, true)
  def __dir__
    File.dirname(__FILE__)
  end
end

module Routes
  CHANNEL = '(?<channel>[\w\-\.]+)'
  DATE    = '(?<date>[\w\-]+)'
  TIME    = '(?<time>[\d\.]+)'
  FORMAT  = '(?<format>[A-Za-z]+)'
  LINE    = '(?<line>\d+)'
end

module Message
  module_function
  def redis
    @redis ||= Redis.new(:thread_safe => true)
  end

  def lrange channel, date, start, stop
    redis.lrange("irclog:channel:##{channel}:#{date}", start, stop).
      map{ |msg| JSON.parse(msg) }
  end

  def last channel, date, numbers
    lrange(channel, date, -numbers, -1)
  end

  def all channel, date
    lrange(channel, date, 0, -1)
  end
end

module Util
  def erb path
    ERB.new(views(path)).result(binding)
  end

  def views path
    @views ||= {}
    @views[path] ||= File.read("#{__dir__}/views/#{path}.erb")
  end

  def escape text
    CGI.escape_html(text)
  end

  def user_action msg
    msg['msg'][/^\u0001ACTION (.*)\u0001$/, 1]
  end

  def user_nick msg
    if user_action(msg)
      '*'
    elsif nick = slack_nick(msg)
      escape("ⓢ #{nick}")
    elsif nick = telegram_nick(msg)
      escape("🅣 #{nick}")
    else
      escape(msg['nick'])
    end
  end

  def slack_data msg
    if msg['nick'].include?('slack') && msg['nick'].include?('bot')
      begin
        return msg['msg'].match(/\A<(.+?)> (.+)\Z/)[1..2]
      rescue
        return []
      end
    else
      []
    end
  end

  def slack_nick msg
    slack_data(msg).first
  end

  def slack_msg msg
    slack_data(msg).last
  end

  def telegram_data msg
    if msg['nick'].include?('benito')
      begin
        return msg['msg'].match(/\A<(.+?)> (.+)\Z/)[1..2]
      rescue
        return []
      end
    else
      []
    end
  end

  def telegram_nick msg
    telegram_data(msg).first
  end

  def telegram_msg msg
    telegram_data(msg).last
  end

  def user_text msg
    if act = user_action(msg)
      "<span class=\"nick\">#{escape(msg['nick'])}</span>" \
      "&nbsp;#{autolink(escape(act))}"
    elsif text = slack_msg(msg)
      autolink(escape(text))
    elsif text = telegram_msg(msg)
      autolink(escape(text))
    else
      autolink(escape(msg['msg']))
    end
  end

  def user_text_without_tags msg
    if act = user_action(msg)
      "*#{escape(act)}*"
    elsif text = slack_msg(msg)
      escape(text)
    elsif text = telegram_msg(msg)
      escape(text)
    else
      escape(msg['msg'])
    end
  end

  def autolink text
    text.gsub(%r{\bhttps?://\S+[\b/]?}) do |m|
      if m.end_with?('&gt;')
        s = m.chomp('&gt;')
        %Q{<a href="#{s}">#{s}</a>&gt;}
      else
        %Q{<a href="#{m}">#{m}</a>}
      end
    end
  end

  def date m
    case m[:date]
    when "today"
      Time.now.strftime("%F")
    when "yesterday"
      (Time.now - 86400).strftime("%F")
    else
      # date in "%Y-%m-%d" format (e.g. 2013-01-01)
      m[:date]
    end
  end

  def render_json msgs
    msgs.each do |m|
      m['nick'], m['msg'] = user_nick(m), user_text(m)
    end
    msgs.to_json
  end
end

module IRC_Log
  class App
    include Jellyfish, Routes
    controller_include Util

    get %r{^/?$} do
      redirect "/channel/k0nsl/today"
    end

    get %r{^/?channel/#{CHANNEL}$} do |m|
      redirect "/channel/#{m[:channel]}/today"
    end

    get %r{^/?channel/#{CHANNEL}/#{DATE}(/#{FORMAT})?$} do |m|
      @date    = date(m)
      @channel = m[:channel]
      @msgs    = Message.all(@channel, @date)

      if m[:format] == 'json'
        headers_merge('Content-Type' => 'application/json; charset=utf-8')
        render_json(@msgs)
      else
        erb :channel
      end
    end

    get %r{^/?channel/#{CHANNEL}/#{DATE}/#{LINE}$} do |m|
      @date    = date(m)
      @channel = m[:channel]
      @line    = m[:line].to_i
      not_found if @line < 0
      @msg     = Message.lrange(@channel, @date, @line, @line).first
      not_found unless @msg
      @url     = CGI.escape(request.url)

      erb :quote
    end

    get %r{^/?live/#{CHANNEL}$} do |m|
      @channel = m[:channel]
      @msgs    = Message.last(@channel, Time.now.strftime('%Y-%m-%d'), 25).
                   select{ |msg| msg['msg'][/^\[\S*\]\s.*/] }.reverse

      erb :live
    end

    get %r{^/?widget/#{CHANNEL}$} do |m|
      @channel = m[:channel]
      @msgs    = Message.last(@channel, Time.now.strftime('%Y-%m-%d'), 25).
                   reverse

      erb :widget
    end

    get %r{^/?oembed(\.(?<type>\w+))?$} do |m|
      not_found unless url = request.params['url']
      match = %r{http://.+/channel/#{CHANNEL}/#{DATE}/#{LINE}}.match(url)

      @channel = match[:channel]
      @date    = date(match)
      line     = match[:line].to_i
      not_found if line < 0
      msg      = Message.lrange(@channel, @date, line, line).first
      not_found unless msg
      @nick    = msg['nick']
      @msg     = user_text_without_tags(msg)

      case m[:type]
        when "xml"
          headers_merge('Content-Type' => 'application/xml; charset=utf-8')
          erb :oembed
        else
          headers_merge('Content-Type' => 'application/json; charset=utf-8')
          {
            :version       => "1.0",
            :type          => "link",
            :title         => "k0nsl-trunk | ##{@channel} | #{@nick}> #{@msg}",
            :author_name   => @nick,
            :providor_name => "k0nsl-trunk",
            :providor_url  => request.base_url
          }.to_json
        end
    end
  end
end

module Comet
  class Trapper < Struct.new(:app)
    def initialize app
      super
      @lock = Mutex.new
    end

    def call env
      trap(@lock) if @lock
      app.call(env)
    end

    def trap lock
      lock.synchronize do
        %w[QUIT TERM INT].each do |sig|
          orig_trap = Signal.trap(sig) do
            Comet::App.quit = true # tell comet that we're quitting
            orig_trap.call
          end
        end
        @lock = nil
      end
    end
  end

  class App
    singleton_class.send(:attr_accessor, :quit)

    include Jellyfish, Routes
    controller_include Util, Module.new{
      def fetch_messages channel, date, time
        msgs = Message.last(channel, date, 10)
        if not msgs.empty? and msgs.last['time'] > time
          msgs[msgs.index{ |m| m['time'] > time }..-1]
        end
      end

      def poll channel, date, time
        # we simply block here because we're in a threaded server anyway
        (0...120).find do
          sleep(0.5)
          msgs = fetch_messages(channel, date, time)
          break msgs if msgs || Comet::App.quit
        end
      end
    }

    get %r{^/?poll/#{CHANNEL}/#{TIME}/updates\.json$} do |m|
      channel, time = m[:channel], m[:time]
      date = Time.at(time.to_f).strftime("%Y-%m-%d")

      render_json(fetch_messages(channel, date, time) ||
                  poll(channel, date, time)           ||
                  [])
    end
  end
end
