FactoryGirl.define do
  factory :edge do
    incoming_vertex {build :vertex}
    outcoming_vertex {build :vertex}
  end
end