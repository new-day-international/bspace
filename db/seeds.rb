puts 'Creating The Commons'
c = Space.create name: 'commons', display_name: 'The Commons'

puts 'creating gk'
u = User.create name: 'Gk', email: 'gk@localhost.com', password: '1234'

r = Role.create name: 'admin'
u.roles << r