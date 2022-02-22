# frozen_string_literal: true

require 'rails_helper'
require 'database_cleaner/active_record'

describe 'Request API', type: :request do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    FactoryBot.create(:realtor, name: 'Real Realtor', address: '2 Home Street', email: 'realtor@example.com', phone_number: '+353 112 221', company: 'tTRC - the Totally Real Company')
    FactoryBot.create(:seller, name: 'John', address: '5 Somewhere Street', email: 'john@example.com', phone_number: '+44 784 380 4570')
    FactoryBot.create(:property, property_type: 'house', address: '5 Somewhere Street', seller_id: 1)
    FactoryBot.create(:deal, property_id: 1, realtor_id: 1, seller_id: 1)
    FactoryBot.create(:survey, touchpoint: 'deal_feedback', respondent_id: 1, object_id: 1, respondent_class: 'seller', object_class: 'deal', score: 10)
    FactoryBot.create(:survey, touchpoint: 'deal_feedback', respondent_id: 1, object_id: 1, respondent_class: 'realtor', object_class: 'deal', score: 10)
    FactoryBot.create(:seller_survey, seller_id: 1, survey_id: 1)
    FactoryBot.create(:realtor_survey, realtor_id: 1, survey_id: 2)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe 'Survey response' do
    it 'creates a new survey response' do
      post '/survey', params: {touchpoint: 'realtor_feedback', respondent_id: 1, object_id: 1, respondent_class: 'seller', object_class: 'realtor', score: 10}
      expect(response.status).to eq(201)
      expect(JSON.parse(response.body)['survey']['id']).to eq 3
    end

    it 'updates an existing survey response' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id')
      params['score'] = 8
      post '/survey', params: params
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['survey']['score']).to eq 8
    end

    it 'rejects a request with non-permitted params' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id')
      params['non_permitted_value'] = 3
      post '/survey', params: params
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)['error']).to eq 'Unpermitted request parameter(s)!'
    end

    it 'rejects a request that could lead to data integrity issues' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id')
      params['respondent_class'] = 'realtor; drop table surveys;'
      post '/survey', params: params
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)['error']).to eq 'Parameters rejected due to data integrity concerns!'
      expect(Survey.count).to be > 0
    end

    it 'rejects a request with missing required params' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id', 'score')
      post '/survey', params: params
      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)['error']).to eq 'Required parameter(s) missing!'
    end

    it 'rejects request with an invalid score' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id')
      params['score'] = 11
      post '/survey', params: params
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['error']).to eq "'11' is not a valid score!"
    end

    it 'rejects a request with non-existent classes' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id')
      params['respondent_class'] = 'non_existent_class'
      post '/survey', params: params
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['error']).to eq "'#{params['respondent_class']}' and / or '#{params['object_class']}' not a valid class."
    end

    it 'rejects a request with invalid respondent id' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id')
      params['respondent_id'] = 0
      post '/survey', params: params
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)['error']).to eq "Invalid #{params['respondent_class'].downcase}_id"
    end

    it 'rejects a request with invalid object id' do
      params = Survey.last.attributes.except('created_at', 'updated_at', 'id')
      params['object_id'] = 0
      post '/survey', params: params
      expect(response.status).to eq(404)
      expect(JSON.parse(response.body)['error']).to eq "Invalid #{params['object_class'].downcase}_id"
    end
  end

  describe 'Request touchpoint' do
    it 'returns all deal_feedback touchpoints' do
      get '/touchpoint', params: { touchpoint: 'deal_feedback' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['deal_feedback'].size).to eq 2
    end

    it 'returns deal_feedbacks with respondent_class = seller touchpoints' do
      get '/touchpoint', params: { touchpoint: 'deal_feedback', respondent_class: 'seller' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['deal_feedback'].size).to eq 1
    end

    it 'returns deal_feedbacks with respondent_class = realtor touchpoints' do
      get '/touchpoint', params: { touchpoint: 'deal_feedback', respondent_class: 'realtor' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['deal_feedback'].size).to eq 1
    end

    it 'returns deal_feedbacks with respondent_class = seller and object_class = deal touchpoints' do
      get '/touchpoint', params: { touchpoint: 'deal_feedback', respondent_class: 'seller', object_class: 'deal' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['deal_feedback'].size).to eq 1
    end

    it 'returns no touchpoints' do
      get '/touchpoint', params: { touchpoint: 'non_existent_feedback' }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['touchpoints']).to be nil
    end
  end
end
