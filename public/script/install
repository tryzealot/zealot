#!/usr/bin/env ruby
#
#########################################
# 穷游移动研发一键启动
# author: icyleaf <icyleaf.cn@gmail.com>
# version: 0.0.1
#########################################


#########################################
# Functions
#########################################

# 终端扩展
class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end

# 终端颜色
module Tty extend self
  def blue; bold 34; end
  def green; bold 32; end
  def yellow; bold 33; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

# 提示字符串输出
def info *args
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end
def warn string
  puts " * #{Tty.red}Warning#{Tty.reset}: #{string.chomp}"
end

def error string
  puts " * #{Tty.yellow}Error#{Tty.reset}: #{string.chomp}"
end

def finish string
  puts " * #{Tty.green}Finish#{Tty.reset}: #{string.chomp}"
end

def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system(*args)
end

def exit *args
  warn args.shell_s and abort
end

def ask *args, &block
  message = args[0]
  switch = args[1]

  info "#{message} [#{switch}]"
  cmd = $stdin.gets.chomp

  puts switch.split ""
  if switch.split("").include?cmd
    yield(cmd)
  else
    error "invaild answer, try again"
    ask *args, &block
  end
end

# 执行 sudo 权限命令
def sudo *args
  info "/usr/bin/sudo", *args
  system "/usr/bin/sudo", *args
end

# 根据 OS X 系统获取输出的字节
def getc  # NOTE only tested on OS X
  system "/bin/stty raw -echo"
  if STDIN.respond_to?(:getbyte)
    STDIN.getbyte
  else
    STDIN.getc
  end
ensure
  system "/bin/stty -raw echo"
end

# 回车继续执行等待
def wait_for_user
  puts
  puts "Press RETURN to continue or any other key to abort"
  c = getc
  # we test for \r and \n because some stuff does \r instead
  abort unless c == 13 or c == 10
end

# 更新 Hosts 文件
def hosts
  hosts_file = "/Users/icyleaf/host1"
  hosts = {
    'mobile.dev': '172.1.1.227',
    'gitlab.dev': '172.1.1.227',

    'www.open_qyer_wiki.com': '172.1.1.231',
    'soa.qyer.com': '172.1.1.231',

    'qyeradmin185860.qyer.com': '115.182.69.207',
    'cmsadmin185860.qyer.com': '115.182.69.207',
  }

  info "Update hosts apply qyer projects"
  `/usr/bin/sudo echo '# Section Start: qyermobile' >> #{hosts_file}` if `grep "Section Start: qyermobile" #{hosts_file}`.empty?

  hosts.each do |domain, ip|
    r = `grep "#{domain}" #{hosts_file}`
    if r.empty?
      `/usr/bin/sudo echo '#{ip} #{domain}' >> #{hosts_file}`
      puts " * #{Tty.green}#{domain}#{Tty.reset} added"
    else
      puts " * #{Tty.yellow}#{domain}#{Tty.reset} is exists"
    end
  end

  `/usr/bin/sudo echo '# Section End: qyermobile' >> #{hosts_file}` if `grep "Section End: qyermobile" #{hosts_file}`.empty?
end

# 安装 oh my zsh
def oh_my_zsh
  info "Install oh my zsh"
  if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh"))
    finish "found ~/.oh-my-zsh"
  else
    ask "install oh-my-zsh? [ynq] " do |answer|
      case answer
      when 'y'
        puts "installing oh-my-zsh"
        system %Q{git clone https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"}
      when 'q'
        exit
      else
        finish "skipping oh-my-zsh, you will need to change ~/.zshrc"
      end
    end
  end
end

# 切换 zsh
def zsh
  info "Switch to zsh"
  if ENV["SHELL"] =~ /zsh/
    finish "using zsh"
  else
    ask "switch to zsh? (recommended) [ynq] " do |answer|
      case answer
      when 'y'
        finish "switching to zsh"
        system %Q{chsh -s `which zsh`}
      when 'q'
        exit
      else
        error "skipping zsh"
      end
    end
  end
end



#########################################
# Script
#########################################
exit "ONLY install on Mac OS X" unless RUBY_PLATFORM.include?"darwin"

hosts
oh_my_zsh
zsh
