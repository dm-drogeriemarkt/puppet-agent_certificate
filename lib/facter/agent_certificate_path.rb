Facter.add(:agent_certificate_path) do
  setcode do
    Puppet.settings[:hostcert]
  end
end
