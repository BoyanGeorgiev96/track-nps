# frozen_string_literal: true

# some comments
class SurveysController < ApplicationController
  before_action :survey_params, only: :survey
  before_action :touchpoint_params, only: :touchpoint

  class InvalidScore < StandardError; end
  class DataIntegrityError < StandardError; end

  def survey
    handle_survey_exception do
      # The range could be expressed via model validations but the score is converted using Integer to make sure it's a whole number.
      # The error raised by Integer will precede the ActiveRecord validations as the API does not need to continue unless a valid score is given
      raise InvalidScore unless (1..10).include? Integer(params[:score])
      # Check if respondent and object classes exist, i.e. are accepted
      respondent_survey_klass = valid_respondent_class
      valid_object?
      existing_survey = find_existing_survey
      if existing_survey
        update_survey(existing_survey)
      else
        create_new_survey(respondent_survey_klass)
      end
    end
  end

  def valid_respondent_class
    # returns the respondent survey class so it can later be used to be used in creating a new ClassSurvey
    "#{params[:respondent_class].capitalize}Survey".constantize
  end

  def find_existing_survey
    respondent_join_sym = "#{params[:respondent_class].downcase}_surveys".to_sym
    Survey.joins(respondent_join_sym).where(respondent_id: params[:respondent_id].to_i,
                                            object_id: params[:object_id].to_i,
                                            respondent_class: params[:respondent_class],
                                            object_class: params[:object_class])[0]
  end

  def update_survey(survey)
    survey.score = Integer(params[:score])
    survey.save!
    render json: { "success": 'Survey response updated',
                   "survey": survey }
  end

  def create_new_survey(respondent_klass)
    ActiveRecord::Base.transaction do
      survey = Survey.new(touchpoint: params[:touchpoint], respondent_id: params[:respondent_id].to_i,
                          respondent_class: params[:respondent_class], object_id: params[:object_id],
                          object_class: params[:object_class], score: Integer(params[:score]))
      survey.save!
      respondent_klass.create!("#{params[:respondent_class].downcase}_id": params[:respondent_id], survey_id: survey.id)
      render json: { "success": 'Survey response created successfully.',
                     "survey": survey},
             status: :created
    end
  end

  def valid_object?
    params[:object_class].capitalize.constantize.find(params[:object_id])
    true
  end

  def touchpoint
    touchpoints = find_touchpoints
    touchpoint_response(touchpoints)
  end

  def find_touchpoints
    respondent_class = params[:respondent_class] || %w[realtor seller]
    object_class = params[:object_class] || %w[realtor deal property]
    Survey.where(touchpoint: params[:touchpoint], respondent_class:, object_class:)
  end

  def touchpoint_response(touchpoints)
    if touchpoints.empty?
      render json: { "touchpoints": nil,
                     "message": 'No such touchpoints exist.',
                     "requested_touchpoint": params[:touchpoint] }
    else
      render json: { "#{params[:touchpoint]}": touchpoints }
    end
  end

  def handle_survey_exception(&block)
    block.call
  rescue NameError
    render json: { "error": "'#{params[:respondent_class]}' and / or '#{params[:object_class]}' not a valid class.",
                   "valid_respondent_classes": "'realtor', 'seller'",
                   "valid_object_classes": "'realtor', 'deal', 'property'" },
           status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid
    render json: { "error": "Invalid #{params[:respondent_class].downcase}_id",
                   "provided_value": params[:respondent_id] },
           status: :not_found
  rescue InvalidScore
    render json: { "error": "'#{params[:score]}' is not a valid score!",
                   "valid_score": '0 <= score <= 10',
                   "valid_score_type": 'integer' },
           status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { "error": "Invalid #{params[:object_class].downcase}_id",
                   "provided_value": params[:object_id] },
           status: :not_found
  end

  private

  def survey_params
    missing_msg = 'Required parameter(s) missing!'
    valid_and_required_params = (Survey.column_names - %w[id created_at updated_at]).map(&:to_sym)
    handle_params_exception(missing_msg, valid_and_required_params, valid_and_required_params) do
      check_data_integrity
      params.require(valid_and_required_params)
      params.permit(valid_and_required_params)
    end
  end

  def touchpoint_params
    missing_msg = 'Required parameter missing!'
    permitted_params = %i[touchpoint respondent_class object_class]
    handle_params_exception(missing_msg, 'touchpoint', permitted_params) do
      check_data_integrity
      params.require(:touchpoint)
      params.permit(permitted_params)
    end
  end

  def handle_params_exception(missing_msg, valid_params, required_params, &block)
    block.call
  rescue ActionController::UnpermittedParameters
    render json: { "error": 'Unpermitted request parameter(s)!',
                   "valid_parameters": valid_params },
           status: :bad_request
  rescue ActionController::ParameterMissing
    render json: { "error": missing_msg,
                   "required_parameters": required_params },
           status: :bad_request
  rescue DataIntegrityError
    render json: { "error": 'Parameters rejected due to data integrity concerns!' },
           status: :bad_request
  end

  # Match only alphanumeric characters and underscores!
  def check_data_integrity
    params.each do |_, v|
      raise DataIntegrityError unless v.match('^[a-zA-Z0-9_]*$')
    end
  end
end
