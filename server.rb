#!/usr/bin/env ruby -w
require "socket"
class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.capitalize.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exist"
            Thread.kill self
          elsif nick_name != other_name
            other_client.puts "#{nick_name} has joined the chat #{Time.now}"
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Connection established, Thank you for joining! Happy chatting"
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
    loop {
      msg = client.gets.chomp
      puts "#{Time.now.strftime("[%I:%M%p]")} #{username.to_s}: #{msg}"
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{Time.now.strftime("[%I:%M%p]")} #{username.to_s}: #{msg}"
        end
      end
    }
  end
end

Server.new( 3000, "localhost" )
