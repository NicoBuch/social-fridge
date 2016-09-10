module Api
  module V1
    class VolunteersController < ApplicationController
      skip_before_action :authenticate_request, only: :fb_connect

      def fb_connect
        context = Omniauth::Facebook::ConnectContext.new(current_user)
        context.handle(fb_params[:access_token])
        status = context.status
        return head status unless [:created, :ok].include? status
        render status: status, json: context.volunteer
      end

      private

      def fb_params
        params.require(:access_token)
        params.permit(:access_token)
      end
    end
  end
end
