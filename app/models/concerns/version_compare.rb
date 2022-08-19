# frozen_string_literal: true

module VersionCompare
  extend ActiveSupport::Concern

  VERSION_REGEX = /((\d+\.?)+)(([-_\.]?\w+)*\d*)?/

  # Returns the boolean truth of source = target
  def same_version(source, target)
    version_compare(source, target) == 0
  end

  # Returns the boolean truth of source > target
  def gt_version(source, target)
    version_compare(source, target) == 1
  end

  # Returns the boolean truth of source >= target
  def ge_version(source, target)
    gt_version(source, target) || same_version(source, target)
  end

  # Returns the boolean truth of source < target
  def lt_version(source, target)
    version_compare(source, target) == -1
  end

  # Returns the boolean truth of source <= target
  def le_version(source, target)
    lt_version(source, target) || same_version(source, target)
  end

  # Version compare
  #
  # source > target return 1
  # source = target return 0
  # source < target return -1
  def version_compare(source, target)
    Gem::Version.new(semver(source)) <=> Gem::Version.new(semver(target))
  end

  # Convert general version to semver
  #
  # android-1.2.3     => 1.2.3
  # 608151815         => 608151815
  # 1                 => 1
  # 1.2.3.4           => 1.2.3.4
  # 4.12.4            => 4.12.4
  # 0.1.0.pre1        => 0.1.0.pre1
  # 0.1.0.alpha.1     => 0.1.0.alpha.1
  # 0.1.0.rc2         => 0.1.0.rc2
  # v1.2.43.33333     => 1.2.43.33333
  # 1.1.beta9         => 1.1.beta9
  # 20200127.013811   => 20200127.013811
  def semver(version)
    return version unless matches = VERSION_REGEX.match(version)

    matches[0]
  end
end
