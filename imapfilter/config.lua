function main()
   -- One of the work mailservers is slow.
   -- The time in seconds for the program to wait for a mail server's response (default 60)
   options.timeout = 120

   -- According to the IMAP specification, when trying to write a message to a non-existent mailbox, the server must send a hint to the client, whether it should create the mailbox and try again or not. However some IMAP servers don't follow the specification and don't send the correct response code to the client. By enabling this option the client tries to create the mailbox, despite of the server's response.
   options.create = true

   -- By enabling this option new mailboxes that were automatically created, get also subscribed; they are set active in order for IMAP clients to recognize them
   options.subscribe = true

   -- Normally, messages are marked for deletion and are actually deleted when the mailbox is closed. When this option is enabled, messages are expunged immediately after being marked deleted.
   options.expunge = true

   cmd = io.popen('pass mail/federico.carrone@gmail.com', 'r')
   out = cmd:read('*a')
   pass = string.gsub(out, '[\n\r]+', '')

   local personal = IMAP {
      server = "imap.gmail.com",
      username = "federico.carrone@gmail.com",
      password = pass,
      ssl = "tls1"
   }

   mails = personal['INBOX']:select_all()

   -- move mailing lists from INBOX to correct folders
   move_mailing_lists(personal, mails)

   -- move spam to spam folder
   move_spam(personal, mails, "[Gmail]/Spam")

   -- delete old spam
   delete_older(personal, "[Gmail]/Spam", 30)

   -- delete old sent
   delete_older(personal, "[Gmail]/Sent Mail", 120)

end

function move_mailing_lists(account, mails)
   -- junk
   delete_older(account, "junk", 30)
   move_if_from_contains(account, mails, "no_reply@email.apple.com", "junk")

   -- calendar
   delete_older_from(account, mails, "calendar-notification@google.com", 5)

   -- bancos
   move_if_from_contains(account, mails, "pcbanking.avisos@hsbc.com.ar", "bancos")
   move_if_from_contains(account, mails, "macro.com.ar", "bancos")
   move_if_from_contains(account, mails, "newsletter@clientesmacro.com.ar", "bancos")
   move_if_from_contains(account, mails, "bancomacro@e-resumen.com.ar", "bancos")
   move_if_from_contains(account, mails, "visa.com.ar", "bancos")

   -- boletas
   delete_older(account, "boletas", 365)
   move_if_from_contains(account, mails, "admarevalo@gmail.com", "boletas")
   move_if_to_contains(account, mails, "admarevalo@gmail.com", "boletas")
   move_if_from_contains(account, mails, "payoneer.com", "boletas")
   move_if_from_contains(account, mails, "amazon.com", "boletas")
   move_if_from_contains(account, mails,"pedidosya.com", "boletas")
   move_if_from_contains(account, mails,"personal.com.ar", "boletas")
   move_if_from_contains(account, mails,"village.com.ar", "boletas")
   move_if_from_contains(account, mails, "osde.com.ar", "boletas")
   move_if_from_contains(account, mails, "lanacion.com.ar", "boletas")
   move_if_from_contains(account, mails, "cablevision.com.ar", "boletas")
   move_if_from_contains(account, mails, "paypal", "boletas")
   move_if_from_contains(account, mails, "spotify.com", "boletas")
   move_if_from_contains(account, mails, "gandi.net", "boletas")
   move_if_from_contains(account, mails, "movistar.com.ar", "boletas")
   move_if_from_contains(account, mails, "vultr.com", "boletas")
   move_if_from_contains(account, mails, "email.sonyentertainmentnetwork.com", "boletas")
   move_if_from_contains(account, mails, "support@offgamers.com", "boletas")
   move_if_from_contains(account, mails, "facturacion@movieclub.com.ar", "promociones")

   -- viajes
   delete_older(account, "viajes", 365)
   move_if_from_contains(account, mails, "renfe", "viajes")
   move_if_from_contains(account, mails, "booking.com", "viajes")
   move_if_from_contains(account, mails, "hello@loco2.com", "viajes")
   move_if_from_contains(account, mails, "iberia.es", "viajes")
   move_if_from_contains(account, mails, "plataforma10.com", "viajes")
   move_if_from_contains(account, mails, "expediamail.com", "viajes")
   move_if_from_contains(account, mails, "latam.com", "viajes")

   -- not a monad tutorial
   move_if_subject_contains(account, mails, "This is not a Monad Tutorial", "not a monad tutorial")

   -- links
   delete_older(account, "links", 30)
   move_if_to_contains(account, mails, "links-programacion@googlegroups.com", "links")

   -- promociones
   delete_older(account, "promociones", 30)
   move_if_from_contains(account, mails, "contacto@promociones-aereas.com.ar", "promociones")
   move_if_from_contains(account, mails, "consultas@avantrip.com", "promociones")

   -- github
   delete_older(account, "github", 30)
   move_if_to_contains(account, mails, "github.com", "github")

   -- libros
   delete_older(account, "libros", 30)
   move_if_from_contains(account, mails, 'support@pragprog.com', "libros")
   move_if_from_contains(account, mails, 'cma@bitemyapp.com', "libros")
   move_if_from_contains(account, mails, 'hello@leanpub.com', "libros")
   move_if_from_contains(account, mails, 'oreilly@post.oreilly.com', "libros")
   move_if_from_contains(account, mails, 'pragmaticbookshelf.com', "libros")
   move_if_from_contains(account, mails, 'manning.com', "libros")

   -- elearning
   delete_older(account, "elearning", 14)
   move_if_from_contains(account, mails, 'courseupdates.edx.org', "elearning")
   move_if_from_contains(account, mails, 'news@edx.org', "elearning")
   move_if_from_contains(account, mails, "noreply@coursera.org", "elearning")

   -- explore
   delete_older(account, "explore", 14)
   move_if_from_contains(account, mails, "noreply@github.com", "explore")
   move_if_from_contains(account, mails, "noreply@medium.com", "explore")
   move_if_from_contains(account, mails, "hello@thinkful.com", "explore")
   move_if_from_contains(account, mails, "weekly@changelog.com", "explore")

   --infoq
   delete_older(account, "ocaml", 14)
   move_if_from_contains(account, mails, "mailer.infoq.com", "infoq")

   -- ocaml
   delete_older(account, "ocaml", 14)
   move_if_to_contains(account, mails, 'mirageos-devel@lists.xenproject.org', "ocaml")

   -- llvm
   delete_older(account, "llvm", 14)
   move_if_from_contains(account, mails, "list@llvmweekly.org", "llvm")

   -- python
   delete_older(account, "python", 14)
   move_if_from_contains(account, mails, "admin@pycoders.com", "python")
   move_if_from_contains(account, mails, "rahul@pythonweekly.com", "python")

   -- pony
   delete_older(account, "pony", 14)
   move_if_to_contains(account, mails, "pony.groups.io", "pony")

   -- databases
   delete_older(account, "databases", 14)
   move_if_from_contains(account, mails, "dbweekly@cooperpress.com", "databases")
   move_if_from_contains(account, mails, "postgres@cooperpress.com", "databases")

   -- clojure
   delete_older(account, "clojure", 14)
   move_if_to_contains(account, mails, "onyx-user@googlegroups.com", "clojure")
   move_if_to_contains(account, mails, "clojure@googlegroups.com", "clojure")
   move_if_from_contains(account, mails, "eric@lispcast.com", "clojure")

   -- elixir
   delete_older(account, "elixir", 21)
   move_if_to_contains(account, mails, "elixir-lang-talk@googlegroups.com", "elixir")
   move_if_to_contains(account, mails, "elixir-lang-core@googlegroups.com", "elixir")
   move_if_to_contains(account, mails, "elixir-lang-core@googlegroups.com", "elixir")
   move_if_from_contains(account, mails, "elixir.radar@plataformatec.com.br", "elixir")

   -- openbsd
   delete_older(account, "openbsd", 14)
   move_if_to_contains(account, mails, "misc@openbsd.org", "openbsd")

   -- suckless
   delete_older(account, "suckless", 14)
   move_if_to_contains(account, mails, "dev@suckless.org", "suckless")

   -- riak
   delete_older(account, "riak", 14)
   move_if_to_contains(account, mails, "riak-users@lists.basho.com", "riak")
   move_if_to_contains(account, mails, "riak-core@lists.basho.com", "riak")

   -- elm
   delete_older(account, "elm", 14)
   move_if_to_contains(account, mails, "elm-discuss@googlegroups.com", "elm")

   -- lwn
   delete_older(account, "lwn", 14)
   move_if_from_contains(account, mails, "lwn@lwn.net", "lwn")

   -- erlang
   delete_older(account, "erlang", 21)
   move_if_to_contains(account, mails, "lisp-flavoured-erlang@googlegroups.com", "erlang")
   move_if_to_contains(account, mails, "erlang-questions@erlang.org", "erlang")
   move_if_to_contains(account, mails, "info@verne.mq", "erlang")

   -- rust
   delete_older(account, "rust", 14)
   move_if_from_contains(account, mails, 'this-week-in-rust@webstream.io', "rust")

   -- smartos
   delete_older(account, "smartos", 14)
   move_if_to_contains(account, mails, 'smartos-discuss@lists.smartos.org', "smartos")

   -- devops
   delete_older(account, "devops", 14)
   move_if_from_contains(account, mails, 'docker@info.docker.com', "devops")
   move_if_from_contains(account, mails, 'gareth@morethanseven.net', "devops")

end

function move_spam(account, mails, spam_mailbox)
   spam_from = {}
   for n, mail_from in ipairs(spam_from) do
      move_if_from_contains(account, mails, mail_from, spam_mailbox)
   end

end

-- helper functions
function move_if_subject_contains(account, mails, subject, mailbox)
    filtered = mails:contain_subject(subject)
    filtered:move_messages(account[mailbox]);
end

function move_if_to_contains(account, mails, to, mailbox)
    filtered = mails:contain_to(to)
    filtered:move_messages(account[mailbox]);
end

function move_if_from_contains(account, mails, from, mailbox)
    filtered = mails:contain_from(from)
    filtered:move_messages(account[mailbox]);
end

function delete_mail_from(account, mails, from)
    filtered = mails:contain_from(from)
    filtered:delete_messages()
end

function delete_mail_if_subject_contains(account, mails, subject)
    filtered = mails:contain_subject(subject)
    filtered:delete_messages()
end

function delete_older(account, mailbox, age)
    filtered = account[mailbox]:is_older(age)
    filtered:delete_messages()
end

function delete_older_from(account, mails, from, age)
    filtered = mails:contain_from(from):is_older(age)
    filtered:delete_messages()
end

main()
