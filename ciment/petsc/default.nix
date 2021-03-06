{ stdenv
, fetchurl
, openblasCompat
, python
, gfortran
, openmpi
, tcsh
, valgrind
, suitesparse
, hwloc
, metis
, superlu
, hdf5
, netcdf
, scalarType ? "complex" # May be "real" or "complex"
}:

stdenv.mkDerivation rec {
  name = "petsc-${version}";
  version = "3.8.3";

  src = fetchurl {
    url = "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-${version}.tar.gz";
    sha256 = "1b1yr93g6df8kx10ri2y26bp3l3w3jv10r80krnarbvyjgnw7y81";
  };

  patches = [ ./petscmpiexec.patch ];

  buildInputs = [ 
    openblasCompat
    python
    gfortran
    openmpi
    tcsh
    valgrind
    suitesparse
    hwloc
    metis
    superlu
    hdf5
    netcdf
  ];

  enableParallelBuilding = true;

  preConfigure = ''
    patchShebangs .
  '';

  configureFlags = let
    sharedLibraryExtension = if stdenv.isDarwin then ".dylib" else ".so";
  in [
      "--with-scalar-type=${scalarType}"
      "--with-debugging=0"
      "--with-mpi=1"
      # PETSc is not threadsafe, disable pthread/openmp (see http://www.mcs.anl.gov/petsc/miscellaneous/petscthreads.html)
      "--with-pthread=0"
      "--with-openmp=0"
      "--with-ssl=0"
      "--with-x=0"
      "--with-mpi-dir=${openmpi}"
      "--with-blas-lapack-lib=${openblasCompat}/lib/libopenblas${sharedLibraryExtension}"
      "--with-valgrind=1"
      "--with-valgrind-dir=${valgrind}"
      "--with-suitesparse-dir=${suitesparse}"
      "--with-hwloc-dir=${hwloc.lib}"
      "--with-netcdf-dir=${netcdf}"
      "--with-hdf5-dir=${hdf5}"
      "--with-superlu-dir=${superlu}"
      "--with-metis-dir=${metis}"
  ];

  postInstall = ''
    rm $out/bin/popup
    rm $out/bin/uncrustify.cfg
    rm -rf $out/bin/win32fe
  '';

  doCheck = true;

  meta = {
    description = "Library of linear algebra algorithms for solving partial differential equations";
    homepage = https://www.mcs.anl.gov/petsc/index.html;
    platforms = stdenv.lib.platforms.all;
    license = stdenv.lib.licenses.bsd2;
  };
}
