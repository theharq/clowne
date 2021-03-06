# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      class UnknownAssociation < StandardError; end

      class Association
        class << self
          def call(source, record, declaration, params:, **_options)
            reflection = source.class.reflections[declaration.name.to_s]

            if reflection.nil?
              raise UnknownAssociation,
                    "Association #{declaration.name} couldn't be found for #{source.class}"
            end

            cloner_class = Associations.cloner_for(reflection)

            cloner_class.new(reflection, source, declaration, params).call(record)

            record
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(
  :association,
  Clowne::Adapters::ActiveRecord::Association,
  before: :nullify
)
