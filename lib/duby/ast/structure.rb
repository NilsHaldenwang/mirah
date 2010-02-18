module Duby::AST
  class Body < Node
    def initialize(parent, line_number, &block)
      super(parent, line_number, &block)
    end

    # Type of a block is the type of its final element
    def infer(typer)
      unless @inferred_type
        if children.size == 0
          @inferred_type = typer.default_type
        else
          children.each {|child| @inferred_type = typer.infer(child)}
        end

        unless @inferred_type
          typer.defer(self)
        end
      end

      @inferred_type
    end
  end

  class Block < Node
    include Scoped
    child :args
    child :body

    def initialize(parent, position, &block)
      super(parent, position, &block)
    end

    def prepare(typer, method)
      interface = method.argument_types[-1]
      outer_class = typer.self_type

    end
  end

  class Noop < Node
    def infer(typer)
      @inferred_type ||= typer.no_type
    end
  end

  class Script < Node
    include Scope
    child :body

    def initialize(parent, line_number, &block)
      super(parent, line_number, children, &block)
    end

    def infer(typer)
      @inferred_type ||= typer.infer(body) || (typer.defer(self); nil)
    end
  end
end