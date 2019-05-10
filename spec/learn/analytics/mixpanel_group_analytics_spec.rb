require 'simple_segment'

##
# Group Analytics
# https://help.mixpanel.com/hc/en-us/articles/360025333632
#
# 'companyId' was a group identifier in our Mixpanel account
#
# Make sure Segment has the same Group Identifier Traits
# in Settings for destinations/mixpanel
##
RSpec.describe 'Mixpanel Group Analytics' do
  let(:group_identifier) { :companyId }

  let(:analytics) {
    SimpleSegment::Client.new(
      write_key: ENV['SEGMENT_WRITE_KEY'],
      on_error: Proc.new { |status, msg| print msg }
    )
  }

  def identify(user_id)
    analytics.identify(
      user_id: user_id,
      traits: {
        email: "#{user_id}@example.com",
        first_name: user_id
      }
    )
  end

  def group(user_id, group_id)
    analytics.group(
      user_id: user_id,
      group_id: group_id,
      traits: {
        group_identifier => group_id,
        trait1: rand(1..20),
        trait2: rand(20..40)
      }
    )
  end

  def track(user_id, company_id)
    analytics.track(
      user_id: user_id,
      event: 'Test Event Created',
      properties: {
        group_identifier => company_id,
      }
    )
  end

  it 'creates user profiles' do
    # Check resutls in Users -> Explore -> by User Id
    identify('test_user_1')
    identify('test_user_2')
    identify('test_user_3')
  end

  it 'creates company profiles' do
    # Check resutls in Users -> Explore -> by Company Id
    group('test_user_1', 'test_company_1')
    group('test_user_2', 'test_company_2')
    group('test_user_3', 'test_company_3')
  end

  it "creates events per company" do
    # Check resutls in Analysis -> Insights -> by Company Id
    # For example:
    #  Show Uniq, Test Event Created
    #  Should count 3 uniq events, i.e. one per company
    track('test_user_1', 'test_company_1')

    track('test_user_2', 'test_company_2')
    track('test_user_3', 'test_company_2')

    track('test_user_4', 'test_company_3')
    track('test_user_5', 'test_company_3')
    track('test_user_6', 'test_company_3')
  end
end
