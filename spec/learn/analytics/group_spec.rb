require 'simple_segment'

##
# Group Analytics
# https://help.mixpanel.com/hc/en-us/articles/360025333632
#
# In Mixpanel account we have CompanyId as an extra custom
# identifier, after User Id
# No extra settings in Segment account were necessary
##
RSpec.describe 'Group Analytics' do
  let(:analytics) {
    SimpleSegment::Client.new(
      write_key: ENV['SEGMENT_WRITE_KEY'],
      on_error: Proc.new { |status, msg| print msg }
    )
  }

  def create_event(user_id:, company_id:, event_name: 'Test Event Created')
    analytics.identify(
      user_id: user_id,
      traits: {
        email: "#{user_id}@example.com",
        first_name: user_id
      }
    )
    analytics.track(
      user_id: user_id,
      event: event_name,
      properties: {
        companyId: company_id
      }
    )
  end

  it "creates event which can be grouped by Company ID" do
    create_event(user_id: 'test_user_1', company_id: 'test_company_1')

    create_event(user_id: 'test_user_2', company_id: 'test_company_2')
    create_event(user_id: 'test_user_3', company_id: 'test_company_2')

    create_event(user_id: 'test_user_4', company_id: 'test_company_3')
    create_event(user_id: 'test_user_5', company_id: 'test_company_3')
    create_event(user_id: 'test_user_6', company_id: 'test_company_3')
  end
end
