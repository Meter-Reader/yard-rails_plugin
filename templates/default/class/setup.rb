# frozen_string_literal: true

def init
  super
  sections.place(:routes).before(:children)
end
