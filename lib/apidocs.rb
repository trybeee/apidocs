module Apidocs
  def self.write_docs
    @apidocs = @@apidocs
    f = File.open('doc/apidocs.html', 'w')
    template = ERB.new(File.open('app/views/apidocs.erb').read, nil, '%')
    f.write(template.result(binding))
    f.close
  end

  def it_should_be_documented(options={})
    options = options.inject({}) do |hash, (k,v)|
      hash[k] = v.inject({}) do |args, (k1, v1)|
        args["<b>#{k1}</b>"] = v1.gsub(/([^\n]{80,}?) /, "\\1<br>" )
        args
      end
      hash
    end

    options[:parameters] ||= {}
    options[:parameters].merge!(pagination_parameters) if options[:supports_pagination]

    doc = {
      :description => description,
      :uri => request.request_uri.gsub(/\?.+$/, ''),
      :method => request.request_method,
      :options => options,
      :request_example => JSON.parse(request.parameters.inject({}) {|hash, (k,v)| hash[k] = v unless ['format', 'action', 'controller'].include?(k); hash }.to_json),
      :response_status => response.status,
      :response_body => format_response_body
    }

    docs_group = described_class.name.gsub(/Controller/, '') 
    @@apidocs ||= {}
    @@apidocs[docs_group] ||= {}
    @@apidocs[docs_group][description_args] = doc
  end

  def format_response_body
    JSON.pretty_generate(JSON.parse(response.body))
  rescue JSON::ParserError => e
    response.body
  end

  def pagination_parameters
    {
      :page => "Pagination. Specify a number of page to return. Default is 1",
      :per_page => "How many records should appear on a page. Default is 10",
    }
  end
end


