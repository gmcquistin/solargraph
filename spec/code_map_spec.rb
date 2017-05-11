describe Solargraph::CodeMap do
  before :all do
    # Unfinished instance variable at 92
    @ivar_code = %(
      class Foo
        def bar
          @bar = ''
        end
        def baz
          @
        end
      end
    )

    # Unfinished class variable at 93
    @cvar_code = %(
      class Foo
        @cvar = ''
        def bar
          @bar = ''
        end
        @
      end
    )

    # Unfinished variable/method at 111
    @lvar_code = %(
      class Foo
        def bar
          @bar = ''
        end
        def baz
          boo = ''
          b
        end
      end
    )
  end

  it "identifies position in def node" do
    code_map = Solargraph::CodeMap.new(code: @ivar_code)
    node = code_map.node_at(92)
    expect(node.type).to eq(:def)
  end

  it "detects instance variables" do
    code_map = Solargraph::CodeMap.new(code: @ivar_code)
    result = code_map.suggest_at(92)
    expect(result.map(&:to_s)).to include('@bar')
  end

  it "identifies position in class node" do
    code_map = Solargraph::CodeMap.new(code: @cvar_code)
    node = code_map.node_at(93)
    expect(node.type).to eq(:class)
  end

  it "detects class variables" do
    code_map = Solargraph::CodeMap.new(code: @cvar_code)
    result = code_map.suggest_at(93)
    expect(result.map(&:to_s)).to include('@cvar')
    expect(result.map(&:to_s)).not_to include('@bar')
  end

  it "detects local variables and instance methods" do
    code_map = Solargraph::CodeMap.new(code: @lvar_code)
    result = code_map.suggest_at(111)
    expect(result.map(&:to_s)).to include('bar')
    expect(result.map(&:to_s)).to include('baz')
    expect(result.map(&:to_s)).to include('boo')
  end

  it "gets instance methods for literals" do
    code_map = Solargraph::CodeMap.new(code: "'string'.")
    result = code_map.suggest_at(9)
    expect(result.map(&:to_s)).to include('upcase')
  end

  it "stubs unfinished instance variables" do
    code_map = Solargraph::CodeMap.new(code: "puts @")
    expect(code_map.parsed).to eq("puts #")
  end

  it "stubs unfinished symbols" do
    code_map = Solargraph::CodeMap.new(code: "symbol :")
    expect(code_map.parsed).to eq("symbol #")
  end

  it "stubs unfinished method calls" do
    code_map = Solargraph::CodeMap.new(code: "String.")
    expect(code_map.parsed).to eq("String#")
  end
end
