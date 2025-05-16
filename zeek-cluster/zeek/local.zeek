@load protocols/http
@load protocols/ssl
redef Log::default_writer = Log::WRITER_PER_WORKER;

