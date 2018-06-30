module Activities
  class InvitesController < ApplicationController
    before_action :load_and_authorize_team, only: [:new, :create, :destroy]
    before_action :load_invitee, only: [:create]

    def new
      @invite = Activity::Invite.new(team: @team)

      render "activites/invites/new"
    end

    def create
      if @team.members.include?(@invitee)
        flash[:notice] = "this user is already a member of the team"
        redirect_to new_team_invite_path(@team) and return
      end

      unless Activity::Invite.where(user: @invitee).blank?
        flash[:notice] = "this user has already been invited to the team"
        redirect_to new_team_invite_path(@team) and return
      end

      if @invitee.blank?
        flash[:notice] = "this user is not a member of myInvestmentTime.com"
        redirect_to new_team_invite_path(@team) and return
      end

      @invite = Activity::Invite.new(team: @team,
                                     member_email: invite_params[:member_email],
                                     user: @invitee)

      if @invite.save
        flash[:notice] = "#{invite_params[:member_email]} has been invited to the team"
        redirect_to new_team_invite_path(@team)
      else
        render "activites/invites/new"
      end
    end

    def update

    end

    def destroy
      @invite = Activity::Invite.find(params[:id])

      if @invite.destroy
        flash[:notice] = "invite has been revoked"
        redirect_to new_team_invite_path(@team)
      else
        flash[:notice] = "there was a problem revoking the invite"
        redirect_to new_team_invite_path(@team)
      end
    end

    private

    def invite_params
      params.require(:activity_invite).permit(:member_email)
    end

    def load_and_authorize_team
      @team = Team.find_by_slug!(params[:team_id])

      unless @team.owner == current_user
        raise CanCan::AccessDenied
      end
    end

    def load_invitee
      @invitee = User.find_by_email(invite_params[:member_email])
    end
  end
end