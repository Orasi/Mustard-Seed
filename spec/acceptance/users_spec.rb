require 'acceptance_header'

resource "Users" do

  let(:user) { create(:user, :admin) }
  let(:user_token) {user.user_token.token}

  header "Accept", "application/json"
  header "Content-Type", "application/json"
  header "User-Token", :user_token

  get "/users" do

    before do
      2.times do |i|
        create(:user)
      end
    end

    example_request "Getting a list of users" do
      expect(response_body).to eql({users: User.all.select(:id, :username, :first_name, :last_name, :company, :admin, :created_at, :updated_at)}.to_json)
      expect(status).to eq(200)
    end
  end

  post "/users" do
    parameter :first_name, "User First Name", :required => true, :scope => :user
    parameter :last_name, "User Last Name", :required => true, :scope => :user
    parameter :username, "Email of user", required: true, :scope => :user
    parameter :password, "User Password", required: true, scope: :user
    parameter :admin, "Boolean if User is Admin"
    parameter :company, "User's Company Name"


    response_field :name, "Name of order", :scope => :order, "Type" => "String"
    response_field :paid, "If the order has been paid for", :scope => :order, "Type" => "Boolean"
    response_field :email, "Email of user that placed the order", :scope => :order, "Type" => "String"

    let(:name) { "Order 1" }
    let(:paid) { true }
    let(:email) { "email@example.com" }

    let(:raw_post) { params.to_json }

    example_request "Creating an order" do
      explanation "First, create an order, then make a later request to get it back"

      order = JSON.parse(response_body)
      expect(order.except("id", "created_at", "updated_at")).to eq({
                                                                       "name" => name,
                                                                       "paid" => paid,
                                                                       "email" => email,
                                                                   })
      expect(status).to eq(201)

      client.get(URI.parse(response_headers["location"]).path, {}, headers)
      expect(status).to eq(200)
    end
  end

  get "/orders/:id" do
    let(:id) { order.id }

    example_request "Getting a specific order" do
      expect(response_body).to eq(order.to_json)
      expect(status).to eq(200)
    end
  end

  put "/orders/:id" do
    parameter :name, "Name of order", :scope => :order
    parameter :paid, "If the order has been paid for", :scope => :order
    parameter :email, "Email of user that placed the order", :scope => :order

    let(:id) { order.id }
    let(:name) { "Updated Name" }

    let(:raw_post) { params.to_json }

    example_request "Updating an order" do
      expect(status).to eq(204)
    end
  end

  delete "/orders/:id" do
    let(:id) { order.id }

    example_request "Deleting an order" do
      expect(status).to eq(204)
    end
  end
end