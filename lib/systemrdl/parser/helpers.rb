# frozen_string_literal: true

module SystemRDL
  class Parser
    parse_helper(:bra) do |c, ignore = true|
      rule = str(c)
      ignore && rule.ignore || rule
    end

    parse_helper(:cket) do |c, ignore = true|
      rule = str(c)
      ignore && rule.ignore || rule
    end
  end
end
