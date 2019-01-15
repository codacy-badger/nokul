# frozen_string_literal: true

namespace :tenant do
  namespace :units do
    desc 'Produce unit sources'
    task :produce do
      %w[raw/yok raw/det].each do |resource|
        puts "Getting changes of #{resource}"
        Nokul::Tenant::Units.update(resource).store comment: <<~COMMENT
          REFER DOCUMENTATION TO EDIT THIS FILE.  PLEASE NOTE THAT:

          - EXISTING RAW ATTRIBUTES WILL NORMALLY BE OVERWRITTEN ON NEXT UPDATE.
          - COMMENTS AND EXTRA BLANK LINES WILL NOT BE PRESERVED.
        COMMENT
      end

      puts 'Updating src/all'
      Nokul::Tenant::Units.produce('src/all').store comment: <<~COMMENT
        AUTOGENERATED FROM SOURCES.  DO NOT EDIT!
      COMMENT
    end
  end
end