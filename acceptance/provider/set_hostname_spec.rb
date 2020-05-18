shared_examples "provider/network/hostname" do |provider, options|
  if !options[:box]
    raise ArgumentError,
      "box option must be specified for provider: #{provider}"
  end

  include_context "acceptance"

  before do
    environment.skeleton("hostname")
    assert_execute("vagrant", "box", "add", "box", options[:box])
    assert_execute("vagrant", "up", "--provider=#{provider}")
  end

  after do
    assert_execute("vagrant", "destroy", "--force")
  end

  it "sets the hostname" do
    status("Test: guest hostname is set")
    result = execute("vagrant", "ssh", "-c", "hostname")
    expect(result.exit_code).to eql(0)
    expect(result.stdout).to match(/test/)

    status("Test: ensure hostname persists after reboot")
    result = execute("vagrant", "ssh", "-c", "sudo reboot")
    result = execute("vagrant", "ssh", "-c", "hostname")
    expect(result.exit_code).to eql(0)
    expect(result.stdout).to match(/test/)
  end
end
