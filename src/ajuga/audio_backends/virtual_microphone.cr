class Ajuga::AudioBackend::VirtualMicrophone < Ajuga::AudioBackend
  @id : String? = nil
  @micfile : File? = nil

  def name : String
    "virtmic"
  end

  def description : String
    "Plays audio over a virtual microphone to communicate in voice chats"
  end

  def play(audio : Audio)
    tmp = File.tempfile("ajuga-audio", audio.extension) do |file|
      file.print(audio.data)
    end
    begin
      process = Process.new("ffmpeg", ["-re", "-i", tmp.path, "-f", "s16le", "-ar", "44100", "-ac", "1", "-y", @micfile.not_nil!.path])
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
    Ajuga.abort "You need to install pulseaudio to use the virtual microphone." unless File.file? "/usr/bin/pactl"
    Ajuga.abort "You need to install ffmpeg to use the virtual microphone." unless File.file? "/usr/bin/ffmpeg"

    random = Random::Secure.urlsafe_base64(6)
    output = IO::Memory.new
    Process.run(command: "pactl", output: output, args: ["load-module", "module-pipe-source", "source_name=\"ajuga-virtmic\"", "file=/tmp/ajuga-virtmic.#{random}.fifo", "format=s16le", "rate=44100", "channels=1"])
    @id = output.to_s.rchop
    @micfile = File.new("/tmp/ajuga-virtmic.#{random}.fifo")
  end

  def finish
    @micfile.try(&.delete())
    Process.run(command: "pactl", args: ["unload-module", @id.not_nil!])
  end
end

Ajuga::AudioBackend << Ajuga::AudioBackend::VirtualMicrophone.new
