module Content
  # Makes an exercise's parts match the content files exactly.
  class PartSync
    # @param exercise [Exercise]
    # @param parts [Hash{Integer=>String}] part number => markdown
    def initialize(exercise, parts)
      @exercise = exercise
      @parts = parts
    end

    # @return [void]
    def call
      @exercise.parts.where.not(number: @parts.keys).delete_all
      @parts.each do |number, markdown|
        @exercise.parts.find_or_initialize_by(number:).update!(description_md: markdown)
      end
    end
  end
end
