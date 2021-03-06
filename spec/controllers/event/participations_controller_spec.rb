# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

require 'spec_helper'

describe Event::ParticipationsController do

  let(:group) { groups(:ch) }

  let(:course) do
    course = Fabricate(:jubla_course, groups: [group], priorization: true)
    course.questions << Fabricate(:event_question, event: course)
    course.questions << Fabricate(:event_question, event: course)
    course.dates << Fabricate(:event_date, event: course)
    course
  end

  let(:other_course) do
    other = Fabricate(:jubla_course, groups: [group], kind: course.kind)
    other.dates << Fabricate(:event_date, event: other, start_at: course.dates.first.start_at)
    other
  end

  let(:participation) do
    p = Fabricate(:event_participation, event: course, application: Fabricate(:jubla_event_application, priority_2: Fabricate(:jubla_course, kind: course.kind)))
    p.answers.create!(question_id: course.questions[0].id, answer: 'juhu')
    p.answers.create!(question_id: course.questions[1].id, answer: 'blabla')
    p
  end


  let(:user) { people(:top_leader) }

  before { sign_in(user); other_course }


  context 'GET index' do
    before do @leader, @advisor, @participant = *create(Event::Role::Leader,
                                                        Event::Course::Role::Advisor,
                                                        course.participant_types.first) end

    it 'lists participant and leader group by default without advisor' do
      get :index, group_id: group.id, event_id: course.id
      expect(assigns(:participations)).to eq [@leader, @participant]
    end

    it 'lists only leader_group without advisor' do
      get :index, group_id: group.id, event_id: course.id, filter: :teamers
      expect(assigns(:participations)).to eq [@leader]
    end

    it 'lists only participant_group' do
      get :index, group_id: group.id, event_id: course.id, filter: :participants
      expect(assigns(:participations)).to eq [@participant]
    end

    def create(*roles)
      roles.map do |role_class|
        role = Fabricate(:event_role, type: role_class.sti_name)
        Fabricate(:event_participation, event: course, roles: [role], active: true)
      end
    end
  end


end
