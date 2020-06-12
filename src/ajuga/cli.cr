module Ajuga
  def self.abort(reason : String)
    STDERR.puts "⚠️ #{reason}\nAborting..".colorize.red
    exit(1)
  end

  def self.run
    if ARGV.size == 0
      self.setup_prompt
    else
      self.parse_cli
    end

    OPTIONS.translation_backend?.try &.prepare
    OPTIONS.audio_backend?.try &.prepare
    OPTIONS.tts_backend?.try &.prepare

    self.prompt
  end

  # def self.show_info
  #   case ARGV[0]
  #     # ADD SUBCOMMANDS TO LIST SPEAKERS/ETC
  #   end
  # end

  def self.parse_cli
    OptionParser.parse(ARGV) do |parser|
      parser.banner = <<-BANNER
      Usage:
        ajuga [arguments]

      An application for communicating with other people via (translated) TTS or text.

      Subcommands:

      BANNER
      parser.on("-i LANGUAGE", "--input=LANGUAGE", "Specifies the language you write in") { |language|
        OPTIONS.input_language = Language.parse?(language)
        self.abort("The input language you chose does not exist!") unless OPTIONS.input_language?
      }
      parser.on("-o LANGUAGE", "--output=LANGUAGE", "Specifies the language to translate to") { |language|
        OPTIONS.output_language = Language.parse?(language)
        self.abort("The output language you chose does not exist!") unless OPTIONS.output_language?
      }
      parser.on("-t NAME", "--translator=NAME", "Specifies the backend used for translation") { |name|
        OPTIONS.translation_backend = TranslationBackend[name]?
        self.abort("The translator you chose does not exist!") unless OPTIONS.translation_backend?
      }
      parser.on("-a NAME", "--audio=NAME", "Specifies the backend used for audio playback") { |name|
        OPTIONS.audio_backend = AudioBackend[name]?
        self.abort("The audio backend you chose does not exist!") unless OPTIONS.audio_backend?
      }
      parser.on("-s NAME", "--speaker=NAME", "Specifies the TTS voice for reading out texts") { |name|
        OPTIONS.tts_backend = TTSBackend[name]?
        self.abort("The TTS voice you chose does not exist!") unless OPTIONS.tts_backend?
      }
      parser.on("-h", "--help", "Show this help") do
        puts parser
        exit
      end
      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts parser
        exit(1)
      end
    end

    self.abort("You didn't specify an input language!") unless OPTIONS.input_language?

    if OPTIONS.output_language? && OPTIONS.output_language != OPTIONS.input_language
      self.abort("You need to specify a translator to output text!") unless OPTIONS.translation_backend?
      self.abort("The translator you chose does not support the given language!") unless OPTIONS.translation_backend.directions.includes?({OPTIONS.input_language, OPTIONS.output_language})
    else
      OPTIONS.translation_backend = nil
      OPTIONS.output_language = OPTIONS.input_language
    end

    if OPTIONS.audio_backend?
      self.abort("You need to specify a TTS voice to play audio!") unless OPTIONS.tts_backend?
      self.abort("The TTS voice you chose does not support the given language!") unless OPTIONS.tts_backend.language == OPTIONS.output_language
    else
      OPTIONS.tts_backend = nil
    end

    self.abort("You didn't specify an output language or an audio backend, leaving nothing to do!") unless OPTIONS.audio_backend? || OPTIONS.translation_backend?
  end

  def self.setup_prompt
    begin
      prompt = Term::Prompt.new
      input_language = prompt.select("Choose an input language:", Language.names, filter: true)
      OPTIONS.input_language = Language.parse input_language.not_nil!

      if prompt.yes?("Would you like to translate the text?")
        output_language = prompt.select("Choose an output language:", Language.names, filter: true)
        OPTIONS.output_language = Language.parse output_language.not_nil!

        translation_backend = prompt.select("Choose a translator:", filter: true) do |menu|
          backends = TranslationBackend.all.select{ |backend| backend.directions.includes?({OPTIONS.input_language, OPTIONS.output_language}) }
          self.abort("There is no translator available for these languages!") if backends.empty?
          backends.each do |backend|
            menu.choice name: backend.name, value: backend.name
          end
        end
        OPTIONS.translation_backend = TranslationBackend[translation_backend.not_nil!]
      else
        OPTIONS.output_language = OPTIONS.input_language
      end

      if OPTIONS.output_language == OPTIONS.input_language || prompt.yes?("Would you like to playback the text?")
        tts_backend = prompt.select("Choose a TTS voice:", filter: true) do |menu|
          backends = TTSBackend.all.select{ |backend| backend.language == OPTIONS.output_language }
          self.abort("There is no tts voice available for the given language!") if backends.empty?
          backends.each do |backend|
            name = String.build do |str|
              str << backend.name
              str << " ("
              str << backend.sex
              if backend.accent
                str << ", "
                str << backend.accent
              end
              str << ")"
            end
            menu.choice name: name, value: backend.name
          end
        end
        OPTIONS.tts_backend = TTSBackend[tts_backend.not_nil!]

        audio_backend = prompt.select("Choose a playback device:", filter: true) do |menu|
          AudioBackend.all.each do |backend|
            menu.choice name: backend.name, value: backend.name
          end
        end
        OPTIONS.audio_backend = AudioBackend[audio_backend.not_nil!]
      end
    rescue ex
      unless ex.is_a?(Term::Reader::InputInterrupt)
        puts "An unknown error caused the program to crash. Error:\n#{ex}".colorize.red
      end
      OPTIONS.tts_backend?.try &.finish
      OPTIONS.translation_backend?.try &.finish
      OPTIONS.audio_backend?.try &.finish
      exit
    end
  end

  def self.powerline
    String.build do |str|
      Colorize.with.back(Colorize::Color256.new(237)).bold.surround(str) do
        str << ' ' << OPTIONS.input_language
        if OPTIONS.translation_backend?
          str << " ➜ " << OPTIONS.output_language
        end
        str << ' '
      end
      Colorize.with.fore(Colorize::Color256.new(237)).back(Colorize::Color256.new(111)).surround(str) do
        str << ''
      end
      Colorize.with.back(Colorize::Color256.new(111)).surround(str) do
        str << ' ' << (OPTIONS.audio_backend? ? '🔊' : '🔇') << ' '
      end
      Colorize.with.fore(Colorize::Color256.new(111)).surround(str) do
        str << ''
      end
      str << ' '
    end
  end

  def self.prompt
    powerline = self.powerline
    reader = Term::Reader.new(interrupt: :error)
    begin
      while input = reader.read_line(powerline).rchop
        next if input.empty?
        text = OPTIONS.translation_backend? ? OPTIONS.translation_backend.translate(OPTIONS.input_language, OPTIONS.output_language, input) : input
        puts "#{''.colorize.white} #{text.colorize.light_yellow}" if OPTIONS.translation_backend?
        if OPTIONS.audio_backend?
          OPTIONS.audio_backend.play OPTIONS.tts_backend.say(text)
          puts "\nPlaying 🔊\n"
        end
      end
    rescue ex
      unless ex.is_a?(Term::Reader::InputInterrupt)
        puts "An unknown error caused the program to crash. Error:\n#{ex.inspect_with_backtrace}".colorize.red
      end
      OPTIONS.tts_backend?.try &.finish
      OPTIONS.translation_backend?.try &.finish
      OPTIONS.audio_backend?.try &.finish
      exit
    end
  end
end
