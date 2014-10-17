#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

include SeedsHelpers

####Add Missing Attributes

#Traveler characteristics
[{klass:Characteristic, characteristic_type: 'personal_factor', code: 'developmentally_disabled', name: 'Developmentally Disabled', note: 'Do you have a developmental disability?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'program', code: 'nemt_eligible', name: 'Medicaid eligible', note: 'Are you eligible for Medicaid?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'disabled_non_elderly', name: 'Disabled (non-elderly)', note: 'Do you have a disability not related to age?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'physically_disabled', name: 'Physically Disabled', note: 'Do you have a physical disability?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'wheelchair_dependent', name: 'Wheelchair Dependent', note: 'Do you require the use of wheelchair?', datatype: 'bool'},

#Traveler accommodations 
{klass:Accommodation, code: 'folding_wheelchair_accessible', name: 'Folding wheelchair accessible', note: 'Do you need a vehicle that has space for a folding wheelchair?', datatype: 'bool'},
{klass:Accommodation, code: 'motorized_wheelchair_accessible', name: 'Motorized wheelchair accessible', note: 'Do you need a vehicle than has space for a motorized wheelchair?', datatype: 'bool'},
{klass:Accommodation, code: 'door_to_door', name: 'Door-to-door', note: 'Do you need assistance getting to your front door?', datatype: 'bool'},
{klass:Accommodation, code: 'curb_to_curb', name: 'Curb-to-curb', note: 'Do you need delivery to the curb in front of your home?', datatype: 'bool'},
{klass:Accommodation, code: 'door_through_door', name: 'Door through door', note: 'Do you need door through door service?', datatype: 'bool'},
{klass:Accommodation, code: 'driver_assistance', name: 'Driver assistance provided', note: 'Do you require assistance from the driver to enter the vehicle?', datatype: 'bool'},
{klass:Accommodation, code: 'wheelchair_lift_equipped', name: 'Wheelchair lift equipped', note: 'Do you require a vehicle equipped with a wheelchair lift?', datatype: 'bool'},
].each do |record|
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

#Trip Purposes
name = 'General Medical'
record = {klass:TripPurpose, code: name.downcase.gsub(%r{[ /]}, '_'), name: name, note: name, active: 1, sort_order: 2}
record[:sort_order] = 1 if record[:code]=='general_purpose'
record[:sort_order] = 3 if record[:code]=='other'
structured_hash = structure_records_from_flat_hash record
build_internationalized_records structured_hash

#County Coverage Areas
['Alachua', 'Baker', 'Bradford', 'Clay', 'Columbia', 'Duval', 'Flagler', 'Nassau', 'Putnam', 'St. Johns', 'Suwannee', 'Union'].each do |c|
  GeoCoverage.find_or_create_by(value: c, coverage_type: 'county_name')
end

#####Remove Unused Attributes

#Eligbility Characteristics
codes = ['developmentally_disabled',
         'nemt_eligible',
         'disabled_non_elderly',
         'physically_disabled',
         'wheelchair_dependent',
         'date_of_birth',
         'age',
         ]

Characteristic.all.each do |c|
  unless c.code.in? codes
    c.delete
  end
end

#Trip Purposes
names = ['Cancer Treatment',
 'General Purpose',
 'Grocery',
 'General Medical']

names.map!{ |name| name.downcase.gsub(%r{[ /]}, '_')}

TripPurpose.all.each do |tp|
  unless tp.code.in? names
    tp.delete
  end
end



