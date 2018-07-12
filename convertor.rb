require 'rest-client'
require 'json'
require 'pry'
require "base64"
require 'cgi'
require 'fileutils'
require 'wavefile'
include WaveFile

class Convertor
  def initialize(content:, cur_time:)
    @content = content
    @cur_time = cur_time
  end

  def convert(index)
    response = RestClient.post(request_url, content, headers)
    sid = response.headers[:sid]
    binding.pry
    if response.headers[:content_type] == "audio/mpeg"
      write_file("audio/#{sid}_#{index}.wav", response.body)
    end
  end

  private

  def write_file(file_name, content)
    base_path = "/Users/shaojunda/apps/text_to_audio"
    dirname = File.dirname("#{base_path}/#{file_name}")
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
    File.open(file_name, "wb") do |file|
      file.write content
    end
  end

  def headers
    {
      "X-Appid": app_id,
      "X-CurTime": @cur_time,
      "X-Param": params,
      "X-CheckSum": check_sum(api_key: api_key, cur_time: @cur_time, params: params),
      "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
    }
  end

  def content
    {
      text: @content
    }
  end

  def request_url
    "http://api.xfyun.cn/v1/service/v1/tts"
  end

  def check_sum(api_key:, cur_time:, params:)
    @check_sum ||= Digest::MD5.hexdigest("#{api_key}#{cur_time}#{params}")
  end

  def api_key
    ""
  end

  def app_id
    ""
  end

  def params
    Base64.strict_encode64({
      "auf": "audio/L16;rate=16000",
      "aue": "raw",
      "voice_name": "xiaoyan",
      "speed": "100",
      "volume": "50",
      "pitch": "50",
      "engine_type": "intp65",
      "text_type": "text"
    }.to_json)
  end
end

def text_content(file_name)
  base_path = "/Users/shaojunda/apps/text_to_audio"
  data = ""
  file = File.open("#{base_path}/#{file_name}", "r")
  file.each_line do |line|
    data += line.chomp
  end
  data.scan(/.{300}/)
end

text_content("example.txt").each.with_index(1) do |content, index|
  cur_time = Time.now.to_i
  Convertor.new(content: content, cur_time: cur_time).convert(index)
end
