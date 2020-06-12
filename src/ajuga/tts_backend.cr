abstract class Ajuga::TTSBackend
  @@backends = {} of String => TTSBackend

  def self.[](name : String) : TTSBackend
    @@backends[name]
  end

  def self.[]?(name : String) : TTSBackend?
    @@backends[name]?
  end

  def self.<<(backend : TTSBackend)
    @@backends[backend.name] = backend
  end

  def self.all : Array(TTSBackend)
    @@backends.values
  end

  abstract def name : String
  abstract def language : Language
  abstract def accent : String?
  abstract def sex : Sex
  abstract def description : String

  abstract def say(text : String) : Audio
  abstract def prepare
  abstract def finish
end
