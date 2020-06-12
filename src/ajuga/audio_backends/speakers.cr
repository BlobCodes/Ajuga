class Ajuga::AudioBackend::Speaker < Ajuga::AudioBackend
  def name : String
    "speaker"
  end

  def description : String
    "Plays audio over your default speakers via sox"
  end

  def play(audio : Audio)
    tmp = File.tempfile("ajuga-audio", audio.extension) do |file|
      file << audio.data
    end
    begin
      process = Process.new("play", [tmp.path, "-q"])
      spawn do
        process.wait
        tmp.delete
      end
    rescue
      puts "Failed to play Audio!".colorize.magenta
      tmp.delete
    end
  end

  def prepare
    Ajuga.abort "You need to install sox to use the speaker output." unless File.file? "/usr/bin/play"
  end

  def finish
  end
end

Ajuga::AudioBackend << Ajuga::AudioBackend::Speaker.new
