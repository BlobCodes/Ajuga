require "http/client"
require "json"

class Ajuga::TranslationBackend::Yandex < Ajuga::TranslationBackend
  APIKEY = "trnsl.1.1.20200411T205004Z.8c50bce2e759de2f.63f7f41d139b43bf0c2a3db8f2af8eb9b18b453d"

  @http_client : HTTP::Client? = nil

  @@directions : Array(Tuple(Language, Language))? = nil

  def name : String
    "yandex"
  end

  def description : String
    "A popular translation engine having lots of languages and generous rate limits"
  end

  def directions : Array(Tuple(Language, Language))
    return @@directions.not_nil! if @@directions

    params = HTTP::Params.encode({"key": APIKEY, "ui": "en"})
    response = HTTP::Client.get("https://translate.yandex.net/api/v1.5/tr.json/getLangs?" + params)
    @@directions = JSON.parse(response.body)["dirs"].as_a.map do |dir|
      splits = dir.as_s.split('-')
      {Language.parse(splits[0]), Language.parse(splits[1])}
    end
  end

  def translate(source : Language, target : Language, text : String) : String
    params = HTTP::Params.encode({"key": APIKEY, "lang": "#{source}-#{target}".downcase, "text": text})
    response = @http_client.not_nil!.get("/api/v1.5/tr.json/translate?" + params)
    JSON.parse(response.body)["text"].as_a[0].as_s
  end

  def prepare
    @http_client = HTTP::Client.new("translate.yandex.net", tls: true)
  end

  def finish
    @http_client.try &.close
  end
end

Ajuga::TranslationBackend << Ajuga::TranslationBackend::Yandex.new()
