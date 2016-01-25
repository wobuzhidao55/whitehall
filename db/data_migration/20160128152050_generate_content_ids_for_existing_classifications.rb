Classification.where(content_id: nil).each do |classification|
  if classification.update_column(:content_id, SecureRandom.uuid)
    print "."
  else
    puts "Classification ##{ classification.id } could not be updated #{ classification.errors.full_messages }"
  end
end
