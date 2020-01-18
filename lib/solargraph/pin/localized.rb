# frozen_string_literal: true

module Solargraph
  module Pin
    module Localized
      # @return [Range]
      attr_reader :presence

      # @param other [Pin::Base] The caller's block
      # @param position [Position, Array(Integer, Integer)] The caller's position
      # @return [Boolean]
      def visible_from?(other, position)
        position = Position.normalize(position)
        other.filename == filename &&
          match_tags(other.full_context.tag, full_context.tag) &&
          (other == closure ||
            (closure.location.range.contain?(closure.location.range.start) && closure.location.range.contain?(other.location.range.ending))
          ) &&
          presence.contain?(position)
      end

      # @param other_loc [Location]
      def visible_at?(other_loc)
        return false if location.filename != other_loc.filename
        presence.include?(other_loc.range.start)
      end

      private

      def match_tags t1, t2
        # @todo This is an unfortunate hack made necessary by a discrepancy in
        #   how tags indicate the root namespace. The long-term solution is to
        #   standardize it, whether it's `Class<>`, an empty string, or
        #   something else.
        t1 == t2 ||
          (['', 'Class<>'].include?(t1) && ['', 'Class<>'].include?(t2))
      end
    end
  end
end
