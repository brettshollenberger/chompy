require "spec_helper"

describe ROpenStruct do
  it "initializes recursively" do
    ostruct = ROpenStruct.new({
      :cool => {
        :dogs => {
          :rule => :hard,
          :are  => :cool,
          :eat => {
            :food => :lots
          }
        },
        :cats => {
          :are => {
            :hard => {
              :to => :find
            },
            :a => :paradox
          }
        }
      }
    })

    expect(ostruct.cool.dogs.rule).to eq :hard
    expect(ostruct.cool.dogs.are).to eq :cool
    expect(ostruct.cool.dogs.eat.food).to eq :lots
    expect(ostruct.cool.cats.are.hard.to).to eq :find
    expect(ostruct.cool.cats.are.a).to eq :paradox
  end
end
