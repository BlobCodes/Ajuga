module Ajuga
  class Options
    property! audio_backend : AudioBackend?
    property! translation_backend : TranslationBackend?
    property! tts_backend : TTSBackend?
    property! input_language : Language?
    property! output_language : Language?

    def initialize
      @audio_backend = nil
      @translation_backend = nil
      @tts_backend = nil
      @input_language = nil
      @output_language = nil
    end
  end
  OPTIONS = Options.new()
end
