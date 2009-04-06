#!/usr/bin/env ruby
require "tmail"
require "makura"

maildir  = File.expand_path(ARGV[1] || "~/Mail")
server   = Makura::Server.new
database = server.database("maildir")
headers  = %w(From To Subject Date Message-Id In-Reply-To List-Id).map(&:downcase)

TMail::Maildir.new(maildir).each { |mail|
  begin
    mail = TMail::Mail.new(mail)
    doc = mail.keys.select { |k| headers.include?(k) }.inject({}) { |doc, header|
      doc.update(header => mail[header].to_s, "body" => mail.body)
    }
    database.save(doc)
  rescue => boom
    $stderr.puts boom.message
    next
  end
}

