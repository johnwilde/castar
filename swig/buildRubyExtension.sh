# run this script from swig/ folder
#
swig -c++ -ruby heyes.i
mv heyes_wrap.cxx ../ext/
cd ../ext/
ruby extconf.rb
make
