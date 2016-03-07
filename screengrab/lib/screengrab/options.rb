require 'fastlane_core'
require 'credentials_manager'

module Screengrab
  class Options
    DEVICE_TYPES = ["phone", "sevenInch", "tenInch", "tv", "wear"].freeze

    # Temporarily make non-Mac environments default to skipping the open summary
    # step until we make it cross-platform
    DEFAULT_SKIP_OPEN_SUMMARY = !FastlaneCore::Helper.mac?

    def self.available_options
      @options ||= [
        FastlaneCore::ConfigItem.new(key: :android_home,
                                     short_option: "-n",
                                     optional: true,
                                     default_value: ENV['ANDROID_HOME'] || ENV['ANDROID_SDK'],
                                     description: "Path to the root of your Android SDK installation, e.g. ~/tools/android-sdk-macosx"),
        FastlaneCore::ConfigItem.new(key: :build_tools_version,
                                     short_option: "-i",
                                     optional: true,
                                     description: "The Android build tools version to use, e.g. '23.0.2'"),
        FastlaneCore::ConfigItem.new(key: :locales,
                                     description: "A list of locales which should be used",
                                     short_option: "-q",
                                     type: Array,
                                     default_value: ['en-US']),
        FastlaneCore::ConfigItem.new(key: :clear_previous_screenshots,
                                     env_name: 'SCREENGRAB_CLEAR_PREVIOUS_SCREENSHOTS',
                                     description: "Enabling this option will automatically clear previously generated screenshots before running screengrab",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :output_directory,
                                     short_option: "-o",
                                     env_name: "SCREENGRAB_OUTPUT_DIRECTORY",
                                     description: "The directory where to store the screenshots",
                                     default_value: File.join("fastlane", "metadata", "android")),
        FastlaneCore::ConfigItem.new(key: :skip_open_summary,
                                     env_name: 'SCREENGRAB_SKIP_OPEN_SUMMARY',
                                     description: "Don't open the summary after running `screengrab`",
                                     default_value: DEFAULT_SKIP_OPEN_SUMMARY,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :app_package_name,
                                     env_name: 'SCREENGRAB_APP_PACKAGE_NAME',
                                     short_option: "-a",
                                     description: "The package name of the app under test (e.g. com.yourcompany.yourapp)",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:package_name)),
        FastlaneCore::ConfigItem.new(key: :tests_package_name,
                                     env_name: 'SCREENGRAB_TESTS_PACKAGE_NAME',
                                     optional: true,
                                     description: "The package name of the tests bundle (e.g. com.yourcompany.yourapp.test)"),
        FastlaneCore::ConfigItem.new(key: :use_tests_in_packages,
                                     env_name: 'SCREENGRAB_USE_TESTS_IN_PACKAGES',
                                     optional: true,
                                     short_option: "-p",
                                     type: Array,
                                     description: "Only run tests in these Java packages"),
        FastlaneCore::ConfigItem.new(key: :use_tests_in_classes,
                                     env_name: 'SCREENGRAB_USE_TESTS_IN_CLASSES',
                                     optional: true,
                                     short_option: "-l",
                                     type: Array,
                                     description: "Only run tests in these Java classes"),
        FastlaneCore::ConfigItem.new(key: :test_instrumentation_runner,
                                     env_name: 'SCREENGRAB_TEST_INSTRUMENTATION_RUNNER',
                                     optional: true,
                                     default_value: 'android.support.test.runner.AndroidJUnitRunner',
                                     description: "The fully qualified class name of your test instrumentation runner"),
        FastlaneCore::ConfigItem.new(key: :ending_locale,
                                     env_name: 'SCREENGRAB_ENDING_LOCALE',
                                     optional: true,
                                     is_string: true,
                                     default_value: 'en-US',
                                     description: "Return the device to this locale after running tests"),
        FastlaneCore::ConfigItem.new(key: :app_apk_path,
                                     env_name: 'SCREENGRAB_APP_APK_PATH',
                                     optional: true,
                                     description: "The path to the APK for the app under test",
                                     short_option: "-k",
                                     default_value: Dir[File.join("app", "build", "outputs", "apk", "app-debug.apk")].last,
                                     verify_block: proc do |value|
                                       UI.user_error! "Could not find APK file at path '#{value}'" unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :tests_apk_path,
                                     env_name: 'SCREENGRAB_TESTS_APK_PATH',
                                     optional: true,
                                     description: "The path to the APK for the the tests bundle",
                                     short_option: "-b",
                                     default_value: Dir[File.join("app", "build", "outputs", "apk", "app-debug-androidTest-unaligned.apk")].last,
                                     verify_block: proc do |value|
                                       UI.user_error! "Could not find APK file at path '#{value}'" unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :specific_device,
                                     env_name: 'SCREENGRAB_SPECIFIC_DEVICE',
                                     optional: true,
                                     description: "Use the device or emulator with the given serial number or qualifier",
                                     short_option: "-s"),
        FastlaneCore::ConfigItem.new(key: :device_type,
                                     env_name: 'SCREENGRAB_DEVICE_TYPE',
                                     description: "Type of device used for screenshots. Matches Google Play Types (phone, sevenInch, tenInch, tv, wear)",
                                     short_option: "-d",
                                     default_value: "phone",
                                     verify_block: proc do |value|
                                       UI.user_error! "device_type must be one of: #{DEVICE_TYPES}" unless DEVICE_TYPES.include?(value)
                                     end)
      ]
    end
  end
end
