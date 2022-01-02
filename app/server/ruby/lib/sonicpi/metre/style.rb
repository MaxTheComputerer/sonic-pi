require_relative "distribution"

module SonicPi
  class Style

    STYLE_LOOKUP = {
      triplet_swing: {
        :beat_divisions => [2,2,2,2],
        :distributions => {
          -1 => [NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333),
            NormalDistribution.new, NormalDistribution.new(0.33333)]
        }
      },

      viennese_waltz: {
        :beat_divisions => [2,2,2],
        :distributions => {
          0 => [NormalDistribution.new, NormalDistribution.new(-0.33333), NormalDistribution.new]
        }
      }
    }

    attr_reader :name, :beat_divisions, :lowest_metrical_level

    def initialize(name, beat_divisions, distributions)
      @name = name
      @beat_divisions = beat_divisions
      @distributions = distributions
      @lowest_metrical_level = @distributions.keys.min
    end

    def sample_distributions
      samples = {}
      @distributions.each do |metrical_level, dist_array|
        samples[metrical_level] = dist_array.map { |dist| dist.sample }
      end
      return samples
    end

    def self.lookup(style_name)
      s = STYLE_LOOKUP[style_name]
      raise "Unknown style #{style_name}" unless s
      return Style.new(style_name, s[:beat_divisions], s[:distributions])
    end
  end
end
