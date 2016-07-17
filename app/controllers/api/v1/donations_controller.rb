module Api
  module V1
    class DonationsController < ApplicationController
      def create
        return render_errors(['User must be a donator']) unless current_user.donator?
        donation = Donation.create(create_params.merge(donator: current_user))
        return render_errors(donation.errors.full_messages) unless donation.valid?
        head :created
      end

      def activate
        return render_errors(['User must be a volunteer']) unless current_user.volunteer?
        donation = Donation.find(params[:id])
        return render_errors(['Inexistent Fridge']) unless valid_fridge?
        donation.update(activate_params.merge(volunteer: current_user, status: :active))
        render json: donation, status: :ok
      end

      def finish
        return render_errors(['User must be a fridge']) unless current_user.fridge?
        donation = Donation.find(params[:id])
        donation.update(fridge: current_user, status: :finished)
        render json: donation, status: :ok
      end

      private

      def create_params
        params.permit(:pickup_time_from, :pickup_time_to, :description)
      end

      def activate_params
        params.permit(:fridge_id)
      end

      def valid_fridge?
        params[:fridge_id].blank? || Fridge.find_by_id(params[:fridge_id]).present?
      end
    end
  end
end
