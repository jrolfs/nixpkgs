{ stdenv, fetchurl, pkgconfig, mod_ca, apr, aprutil }:

stdenv.mkDerivation rec {
  pname = "mod_csr";
  version = "0.2.1";

  src = fetchurl {
    url = "https://redwax.eu/dist/rs/${pname}-${version}.tar.gz";
    sha256 = "01sdvv07kchdd6ssrmd2cbhj50qh2ibp5g5h6jy1jqbzp0b3j9ja";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ mod_ca apr aprutil ];
  inherit (mod_ca) configureFlags installFlags;

  # After openssl-1.0.2t, starting in  openssl-1.1.0l
  # parts of the OpenSSL struct API was replaced by
  # getters - but some setters where forgotten.
  #
  # It is expected that these are back/retrofitted in version
  # openssl-1.1.1d -- but while fixing this it was found
  # that there were quite a few other setters missing and
  # that some of the memory management needed was at odds
  # with the principles used sofar.
  #
  # See https://github.com/openssl/openssl/pull/10563
  #
  # So as a stopgap - use a minimalist compat. layer
  # https://source.redwax.eu/projects/RS/repos/mod_csr/browse/openssl_setter_compat.h
  #
  preBuild = "cp ${./openssl_setter_compat.h} openssl_setter_compat.h";

  meta = with stdenv.lib; {
    description = "RedWax CA service module to handle Certificate Signing Requests";

    homepage = "https://redwax.eu";
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ dirkx ];
  };
}
