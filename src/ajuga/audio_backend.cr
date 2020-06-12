abstract class Ajuga::AudioBackend
  @@backends = {} of String => AudioBackend

  def self.[](name : String) : AudioBackend
    @@backends[name]
  end

  def self.[]?(name : String) : AudioBackend?
    @@backends[name]?
  end

  def self.<<(backend : AudioBackend)
    @@backends[backend.name] = backend
  end

  def self.all : Array(AudioBackend)
    @@backends.values
  end

  abstract def name : String
  abstract def description : String

  abstract def play(audio : Audio)
  abstract def prepare
  abstract def finish
end
