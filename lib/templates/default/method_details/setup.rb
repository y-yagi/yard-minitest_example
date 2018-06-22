def init
  super
  sections.last.place(:examples).before(:source)
end
