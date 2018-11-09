# frozen_string_literal: true

class UnitAbbreviationsPresentRule < Ruling::Rule
  synopsis 'Unit abbreviations must be present'
  subject :unit

  rule 'abbreviation must be present' do
    spot detail if unit.abbreviation.blank?
  end

  private

  FORMATTER = proc { |**param| format('%<label>24s: %<item>s', **param) }

  def detail
    [
      { label: 'Offending unit', item: unit.name }
    ].map { |args| FORMATTER.call(**args) }.join "\n"
  end
end