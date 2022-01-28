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
          0 => [NormalDistribution.new, NormalDistribution.new(-0.6114, 0.02036), NormalDistribution.new(-0.07811, 0.2109)]
        }
      },

      jembe_suku: {
        :beat_divisions => [3,3,3,3],
        :distributions => {
          -1 => [NormalDistribution.new(0, 0.05892), NormalDistribution.new(-0.1331, 0.08848), NormalDistribution.new(-0.01906, 0.07308),
            NormalDistribution.new(0.01449, 0.06796), NormalDistribution.new(-0.1108, 0.08602), NormalDistribution.new(0.0002142, 0.09496),
            NormalDistribution.new(0.03905, 0.07029), NormalDistribution.new(-0.1214, 0.08488), NormalDistribution.new(-0.01752, 0.07722),
            NormalDistribution.new(-0.0005375, 0.07086), NormalDistribution.new(-0.1659, 0.07611), NormalDistribution.new(-0.01680, 0.07935)]
        }
      },

      jembe_manjanin: {
        :beat_divisions => [3,3,3,3],
        :distributions => {
          -1 => [NormalDistribution.new(0, 0.07372), NormalDistribution.new(-0.1630, 0.1158), NormalDistribution.new(0.01148, 0.08321),
            NormalDistribution.new(0.01126, 0.08266), NormalDistribution.new(-0.1582, 0.08967), NormalDistribution.new(0.01422, 0.09576),
            NormalDistribution.new(0.01035, 0.08218), NormalDistribution.new(-0.1391, 0.1096), NormalDistribution.new(-0.01251, 0.09243),
            NormalDistribution.new(0.009116, 0.08766), NormalDistribution.new(-0.2156, 0.08846), NormalDistribution.new(-0.01110, 0.1115)]
        }
      },

      jembe_maraka: {
        :beat_divisions => [3,3,3,3],
        :distributions => {
          -1 => [NormalDistribution.new(0, 0.06510), NormalDistribution.new(0.1481, 0.08497), NormalDistribution.new(0.1596, 0.07256),
            NormalDistribution.new(0.0008616, 0.07582), NormalDistribution.new(0.1799, 0.08771), NormalDistribution.new(0.1646, 0.1039),
            NormalDistribution.new(-0.02685, 0.07677), NormalDistribution.new(0.1797, 0.08133), NormalDistribution.new(0.1462, 0.07712),
            NormalDistribution.new(-0.02662, 0.07507), NormalDistribution.new(0.1558, 0.07851), NormalDistribution.new(0.1022, 0.08918)]
        }
      },

      jembe_woloso: {
        :beat_divisions => [3,3,3,3],
        :distributions => {
          -1 => [NormalDistribution.new(0, 0.06774), NormalDistribution.new(-0.2152, 0.1094), NormalDistribution.new(-0.05884, 0.7451),
            NormalDistribution.new(0.009040, 0.08022), NormalDistribution.new(-0.1883, 0.09199), NormalDistribution.new(-0.04963, 0.08294),
            NormalDistribution.new(0.01051, 0.08178), NormalDistribution.new(-0.1865, 0.09000), NormalDistribution.new(-0.05451, 0.08037),
            NormalDistribution.new(0.009081, 0.08183), NormalDistribution.new(-0.2084, 0.08351), NormalDistribution.new(-0.1001, 0.08927)]
        }
      }
    }

    attr_reader :name, :beat_divisions, :lowest_metrical_level

    # Beat divisions is a list of integers representing the number of pulse units each beat is divided into
    # Distributions is a hash of metrical levels (e.g. 0, -1, etc.) to a list containing a distribution for each metrical location in that level
    # Any probability distribution can be used as long as its class has a sample() method
    def initialize(name, beat_divisions, distributions)
      @name = name
      @beat_divisions = beat_divisions
      @distributions = distributions
      @lowest_metrical_level = @distributions.keys.min
    end

    # Generate samples from each distribution for each metrical level
    # Returns a hash of metrical levels to lists of samples
    def sample_distributions
      samples = {}
      @distributions.each do |metrical_level, dist_array|
        samples[metrical_level] = dist_array.map { |dist| dist.sample }
      end
      return samples
    end

    # Static method to lookup a style preset from its symbol
    # Creates and returns the corresponding Style object
    def self.lookup(style_name)
      s = STYLE_LOOKUP[style_name]
      raise "Unknown style #{style_name}" unless s
      return Style.new(style_name, s[:beat_divisions], s[:distributions])
    end
  end
end
