require "http/client"
require "json"
require "uri"

# A TTS service with lots of available voices and languages
class Ajuga::TTSBackend::TTSMP3 < Ajuga::TTSBackend
  @http_client : HTTP::Client? = nil

  @name : String
  @language : Language
  @accent : String?
  @sex : Sex

  getter name : String
  getter language : Language
  getter accent : String?
  getter sex : Sex

  def initialize(@name, @language, @sex, @accent = nil)
  end

  def description : String
    "An online TTS service with many voices and languages"
  end

  def say(string : String) : Audio
    response = @http_client.not_nil!.post("/makemp3_new.php", form: {"msg" => string, "lang" => @name, "source" => "ttsmp3"})
    json = JSON.parse(response.body)
    Ajuga.abort "TTSMP3 returned an error!" unless json["Error"] == 0
    Audio.new(
      @http_client.not_nil!.get(
        URI.parse(json["URL"].as_s).full_path
      ).body,
      ".mp3"
    )
  end

  def prepare
    @http_client = HTTP::Client.new("ttsmp3.com", tls: true)
  end

  def finish
    @http_client.try &.close
  end
end

[
  {name: "Zeina", language: Ajuga::Language::AR, sex: Ajuga::Sex::Female},
  {name: "Russell", language: Ajuga::Language::EN, sex: Ajuga::Sex::Male, accent: "Australian"},
  {name: "Nicole", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "Australian"},
  {name: "Vitoria", language: Ajuga::Language::PT, sex: Ajuga::Sex::Female, accent: "Brazilian"},
  {name: "Ricardo", language: Ajuga::Language::PT, sex: Ajuga::Sex::Male, accent: "Brazilian"},
  {name: "Camila", language: Ajuga::Language::PT, sex: Ajuga::Sex::Female, accent: "Brazilian"},
  {name: "Amy", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "British"},
  {name: "Brian", language: Ajuga::Language::EN, sex: Ajuga::Sex::Male, accent: "British"},
  {name: "Emma", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "British"},
  {name: "Chantal", language: Ajuga::Language::FR, sex: Ajuga::Sex::Female, accent: "Canadian"},
  {name: "Enrique", language: Ajuga::Language::ES, sex: Ajuga::Sex::Male, accent: "Castilian"},
  {name: "Lucia", language: Ajuga::Language::ES, sex: Ajuga::Sex::Female, accent: "Castilian"},
  {name: "Conchita", language: Ajuga::Language::ES, sex: Ajuga::Sex::Female, accent: "Castilian"},
  {name: "Zhiyu", language: Ajuga::Language::ZH, sex: Ajuga::Sex::Female, accent: "Mandarin"},
  {name: "Mads", language: Ajuga::Language::DA, sex: Ajuga::Sex::Male},
  {name: "Naja", language: Ajuga::Language::DA, sex: Ajuga::Sex::Female},
  {name: "Ruben", language: Ajuga::Language::DA, sex: Ajuga::Sex::Male},
  {name: "Lotte", language: Ajuga::Language::DA, sex: Ajuga::Sex::Female},
  {name: "Celine", language: Ajuga::Language::FR, sex: Ajuga::Sex::Female},
  {name: "Lea", language: Ajuga::Language::FR, sex: Ajuga::Sex::Female},
  {name: "Mathieu", language: Ajuga::Language::FR, sex: Ajuga::Sex::Male},
  {name: "Vicki", language: Ajuga::Language::DE, sex: Ajuga::Sex::Female},
  {name: "Marlene", language: Ajuga::Language::DE, sex: Ajuga::Sex::Female},
  {name: "Hans", language: Ajuga::Language::DE, sex: Ajuga::Sex::Male},
  {name: "Dora", language: Ajuga::Language::IS, sex: Ajuga::Sex::Female},
  {name: "Karl", language: Ajuga::Language::IS, sex: Ajuga::Sex::Male},
  {name: "Raveena", language: Ajuga::Language::EN, sex: Ajuga::Sex::Male, accent: "Indian"},
  {name: "Aditi", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "Indian"},
  {name: "Giorgio", language: Ajuga::Language::IT, sex: Ajuga::Sex::Male},
  {name: "Carla", language: Ajuga::Language::IT, sex: Ajuga::Sex::Female},
  {name: "Bianca", language: Ajuga::Language::IT, sex: Ajuga::Sex::Female},
  {name: "Mizuki", language: Ajuga::Language::JA, sex: Ajuga::Sex::Female},
  {name: "Takumi", language: Ajuga::Language::JA, sex: Ajuga::Sex::Male},
  {name: "Seoyeon", language: Ajuga::Language::KO, sex: Ajuga::Sex::Female},
  {name: "Mia", language: Ajuga::Language::ES, sex: Ajuga::Sex::Female, accent: "Mexican"},
  {name: "Liv", language: Ajuga::Language::NO, sex: Ajuga::Sex::Female},
  {name: "Jacek", language: Ajuga::Language::PL, sex: Ajuga::Sex::Male},
  {name: "Maja", language: Ajuga::Language::PL, sex: Ajuga::Sex::Male},
  {name: "Jan", language: Ajuga::Language::PL, sex: Ajuga::Sex::Female},
  {name: "Ewa", language: Ajuga::Language::PL, sex: Ajuga::Sex::Male},
  {name: "Ines", language: Ajuga::Language::PT, sex: Ajuga::Sex::Female},
  {name: "Cristiano", language: Ajuga::Language::PT, sex: Ajuga::Sex::Male},
  {name: "Carmen", language: Ajuga::Language::RO, sex: Ajuga::Sex::Female},
  {name: "Maxim", language: Ajuga::Language::RU, sex: Ajuga::Sex::Male},
  {name: "Tatyana", language: Ajuga::Language::RU, sex: Ajuga::Sex::Female},
  {name: "Astrid", language: Ajuga::Language::SV, sex: Ajuga::Sex::Female},
  {name: "Filiz", language: Ajuga::Language::TR, sex: Ajuga::Sex::Female},
  {name: "Joey", language: Ajuga::Language::EN, sex: Ajuga::Sex::Male, accent: "American"},
  {name: "Kimberly", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "American"},
  {name: "Salli", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "American"},
  {name: "Ivy", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "American"},
  {name: "Joanna", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "American"},
  {name: "Matthew", language: Ajuga::Language::EN, sex: Ajuga::Sex::Male, accent: "American"},
  {name: "Kendra", language: Ajuga::Language::EN, sex: Ajuga::Sex::Female, accent: "American"},
  {name: "Justin", language: Ajuga::Language::EN, sex: Ajuga::Sex::Male, accent: "American"},
  {name: "Penelope", language: Ajuga::Language::ES, sex: Ajuga::Sex::Female, accent: "American"},
  {name: "Lupe", language: Ajuga::Language::ES, sex: Ajuga::Sex::Female, accent: "American"},
  {name: "Miguel", language: Ajuga::Language::ES, sex: Ajuga::Sex::Male, accent: "American"},
  {name: "Gwyneth", language: Ajuga::Language::CY, sex: Ajuga::Sex::Female},
  {name: "Geraint", language: Ajuga::Language::EN, sex: Ajuga::Sex::Male, accent: "Welsh"}
].each do |speaker|
  Ajuga::TTSBackend << Ajuga::TTSBackend::TTSMP3.new(speaker["name"], speaker["language"], speaker["sex"], speaker["accent"]?)
end

