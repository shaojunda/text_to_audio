require 'wavefile'
include WaveFile

FILES_TO_APPEND = ["1.wav", "2.wav"]

base_path = "/Users/shaojunda/apps/text_to_audio/audio"

OUTPUT_FORMAT = Format.new(:stereo, :pcm_32, 16000)

Writer.new("#{base_path}/append.wav", OUTPUT_FORMAT) do |writer|
  FILES_TO_APPEND.each do |file_name|
    Reader.new("#{base_path}/#{file_name}").each_buffer do |buffer|
      writer.write(buffer)
    end
  end
end
