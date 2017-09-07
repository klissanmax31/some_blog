require 'validators/rate_validator.rb'
class RatesController < ApplicationController
  def evaluate_post
    respond_to do |format|
      @rate = Rate.new(rate_params)
      rate_validator = RateValidator.new(@rate)
      if rate_validator.valid?
        @average_rate = Post.evaluate_post(@rate)
        format.json {render json: @average_rate, status: 200}
      else
        format.json {render json: rate_validator.errors, status: 200}
      end
    end
  end

  private
  def rate_params
    params.require(:rate).permit(:post_id, :value)
  end
end
