class Duktape < Formula
  desc "Embeddable Javascript engine with compact footprint"
  homepage "http://duktape.org"
  url "https://duktape.org/duktape-2.4.0.tar.xz"
  sha256 "86a89307d1633b5cedb2c6e56dc86e92679fc34b05be551722d8cc69ab0771fc"

  def install
    inreplace "Makefile.sharedlibrary" do |s|
      s.gsub! "-soname", "-install_name"
      s.gsub! %r{\/usr\/local}, prefix
      #s.gsub! "libduktape.so.$(REAL_VERSION)", "libduktape.$(REAL_VERSION).so"
      #s.gsub! "libduktaped.so.$(REAL_VERSION)", "libduktaped.$(REAL_VERSION).so"
      #s.gsub! "libduktape.so.$(SONAME_VERSION)", "libduktape.$(SONAME_VERSION).so"
      #s.gsub! "libduktaped.so.$(SONAME_VERSION)", "libduktaped.$(SONAME_VERSION).so"
    end
    system "make", "-f", "Makefile.sharedlibrary"
    mkdir lib
    mkdir include
    system "make", "-f", "Makefile.sharedlibrary", "install"
  end

  test do
    (testpath/"test.cc").write <<~EOS
      #include <stdio.h>
      #include \"duktape.h\"
      int main(int argc, char *argv[]) {
        duk_context *ctx = duk_create_heap_default();
        duk_eval_string(ctx, \"1+2\");
        printf(\"1+2=%d\\n\", (int) duk_get_int(ctx, -1));
        duk_destroy_heap(ctx);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-lduktape",
           testpath/"test.cc", "-o", testpath/"test"
    assert_equal "1+2=3", shell_output(testpath/"test").strip, "Duktape can add number"
  end
end
