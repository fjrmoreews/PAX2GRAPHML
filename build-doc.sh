
IMAGENAME=pax2graphml

 
cd ..
docker run -it -v $PWD:/work -w /work -u root $IMAGENAME bash -c "cd docs && make html" 

 

