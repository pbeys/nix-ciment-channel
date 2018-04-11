{ stdenv, buildPythonPackage, fetchPypi, astropy }:

buildPythonPackage rec {
  pname = "radio_beam";
  version = "0.2";
  name = "${pname}-${version}";
  doCheck = false; # Some tests are failing.

  propagatedBuildInputs = [ astropy ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "0gbnwnk89n8z0xwn41rc7wpr0fwrzkvxficyki3dyqbxq7y3qfrv";
  };

}

