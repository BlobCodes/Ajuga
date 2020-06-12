abstract class Ajuga::TranslationBackend
  @@backends = {} of String => TranslationBackend

  def self.[](name : String) : TranslationBackend
    @@backends[name]
  end

  def self.[]?(name : String) : TranslationBackend?
    @@backends[name]?
  end

  def self.<<(backend : TranslationBackend)
    @@backends[backend.name] = backend
  end

  def self.all : Array(TranslationBackend)
    @@backends.values
  end

  abstract def name : String
  abstract def description : String
  abstract def directions : Array(Tuple(Language, Language))

  abstract def translate(source : Language, target : Language, text : String) : String
  abstract def prepare
  abstract def finish
end
