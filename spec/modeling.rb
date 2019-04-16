require File.expand_path '../spec_helper.rb', __FILE__

describe User do
    it {should have_property        :id}
    it {should have_property        :first_name}
    it {should have_property        :middle_name}
    it {should have_property        :last_name}
    it {should have_property        :phone_number}
    it {should have_property        :emergency_number}
    it {should have_property        :email}
    it {should have_property        :pass_code}
    it {should have_property        :created_at}
    it {should have_property        :role_id}
end