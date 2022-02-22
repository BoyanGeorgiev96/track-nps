Realtor.create!(name: "Real Realtor", address: "2 Home Street", email: "realtor@example.com", phone_number: "+353 112 221", company: "tTRC - the Totally Real Company")
Seller.create!(name: "John", address: "5 Somewhere Street", email: "john@example.com", phone_number: "+44 784 380 4570")
Property.create!(property_type: "house", address: "5 Somewhere Street", seller_id: 1)
Deal.create!(property_id: 1, realtor_id: 1, seller_id: 1)
