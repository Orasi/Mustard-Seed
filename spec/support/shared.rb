
shared_context 'an unauthenticated request' do
  it 'and returns an UNAUTHORIZED (401) status code' do
    expect(last_response.status).to eq(401)
  end

  it 'and returns an error messages' do
    expect(last_response.body).to include('error')
  end
end

shared_context 'a successful request' do
  it 'and returns an OK (200) status code' do
    expect(last_response.status).to eq(200)
  end

  it "and don't include error" do
    expect(last_response.body).not_to include('error')
  end
end

shared_context 'a forbidden request' do
  it 'and returns a FORBIDDEN (403) status code' do
    expect(last_response.status).to eq(403)
  end

  it 'and returns an error messages' do
    expect(last_response.body).to include('error')
  end
end

shared_context 'a not found request' do
  it 'and returns a NOT FOUND (404) status code' do
    expect(last_response.status).to eq(404)
  end

  it 'and returns an error messages' do
    expect(last_response.body).to include('error')
  end
end

shared_context 'a bad request' do
  it 'and returns a BAD REQUESET (400) status code' do
    expect(last_response.status).to eq(400)
  end

  it 'and returns an error messages' do
    expect(last_response.body).to include('error')
  end
end