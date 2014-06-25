require 'spec_helper'

feature 'Test' do
  scenario 'index' do
    visit '/test_form/index'
    expect(page).to have_content 'Form'
  end
end